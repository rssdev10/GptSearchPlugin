using .GptPluginServer: Document, DocumentChunk, DocumentChunkMetadata

using UUIDs

using BytePairEncoding: gpt2_codemap, GPT2Tokenization, Merge, BPE, BPETokenization
using TextEncodeBase: TextEncodeBase, FlatTokenizer, CodeNormalizer, Sentence, getvalue, CodeUnMap
using Downloads

# Global variables
tokenizer = let
    bpe = BPE(Downloads.download("https://s3.amazonaws.com/models.huggingface.co/bert/gpt2-merges.txt"))
    FlatTokenizer(CodeNormalizer(BPETokenization(GPT2Tokenization(), bpe), gpt2_codemap()))

    #     tiktoken.get_encoding(
    #     "cl100k_base"
    # )  # The encoding scheme to use for tokenization
end

encode(text::AbstractString) = tokenizer(Sentence(text))

function decode(tokens::Vector{TextEncodeBase.TokenStage})::String
    unmap = CodeUnMap(tokenizer.tokenization.codemap)
    map(unmap ∘ getvalue, tokens) |> join
end

# Constants
const CHUNK_SIZE = 200  # The target size of each text chunk in tokens
const MIN_CHUNK_SIZE_CHARS = 350  # The minimum size of each text chunk in characters
const MIN_CHUNK_LENGTH_TO_EMBED = 5  # Discard chunks shorter than this
const EMBEDDINGS_BATCH_SIZE = parse(Int, get(ENV, "OPENAI_EMBEDDING_BATCH_SIZE", "128"))  # The number of embeddings to request at a time
const MAX_NUM_CHUNKS = 10000  # The maximum number of chunks to generate from a text


"""
Split a text into chunks of ~CHUNK_SIZE tokens, based on punctuation and newline boundaries.

Args:
    text: The text to split into chunks.
    chunk_token_size: The target size of each chunk in tokens, or None to use the default CHUNK_SIZE.

Returns:
    A list of text chunks, each of which is a string of ~CHUNK_SIZE tokens.
"""
function get_text_chunks(text::String, chunk_token_size=0)::Vector{<:AbstractString}
    # Return an empty list if the text is empty or whitespace
    isempty(text) && return []

    # Tokenize the text
    tokens = encode(text)

    # Initialize an empty list of chunks
    chunks = String[]

    # Use the provided chunk token size or the default one
    chunk_size = iszero(chunk_token_size) ? CHUNK_SIZE : chunk_token_size

    # Initialize a counter for the number of chunks
    num_chunks = 0

    # Loop until all tokens are consumed
    while !isempty(tokens) && num_chunks < MAX_NUM_CHUNKS
        # Take the first chunk_size tokens as a chunk
        chunk = tokens[begin:min(chunk_size, end)]

        # Decode the chunk into text
        chunk_text = decode(chunk)

        # Skip the chunk if it is empty or whitespace
        if isempty(chunk_text)
            # Remove the tokens corresponding to the chunk text from the remaining tokens
            tokens = tokens[length(chunk) :end]
            # Continue to the next iteration of the loop
            continue
        end

        # Find the last period or punctuation mark in the chunk
        last_punctuation =
            filter(!isnothing,
                [
                    findlast('.', chunk_text),
                    findlast('?', chunk_text),
                    findlast('!', chunk_text),
                    findlast('\n', chunk_text)
                ]
            ) |> list -> isempty(list) ? nothing : max(list...)

        # If there is a punctuation mark, and the last punctuation index is before MIN_CHUNK_SIZE_CHARS
        if !isnothing(last_punctuation) && last_punctuation > MIN_CHUNK_SIZE_CHARS
            range_end_index = min(
                lastindex(chunk_text),
                nextind(chunk_text, last_punctuation)
            )
            # Truncate the chunk text at the punctuation mark
            chunk_text = chunk_text[begin:range_end_index]
        end

        # Remove any newline characters and strip any leading or trailing whitespace
        chunk_text_to_append = replace(chunk_text, "\n" => " ") |> strip

        if length(chunk_text_to_append) > MIN_CHUNK_LENGTH_TO_EMBED
            # Append the chunk text to the list of chunks
            push!(chunks, chunk_text_to_append)
        end

        # Remove the tokens corresponding to the chunk text from the remaining tokens
        tokens = tokens[length(encode(chunk_text)):end]

        # Increment the number of chunks
        num_chunks += 1
    end

    # Handle the remaining tokens
    if !isempty(tokens)
        remaining_text = decode(tokens) |> str -> replace(str, "\n" => " ") |> strip
        if length(remaining_text) > MIN_CHUNK_LENGTH_TO_EMBED
            push!(chunks, remaining_text)
        end
    end

    return chunks
end

"""
Create a list of document chunks from a document object and return the document id.

Args:
    doc: The document object to create chunks from. It should have a text attribute and optionally an id and a metadata attribute.
    chunk_token_size: The target size of each chunk in tokens, or None to use the default CHUNK_SIZE.

Returns:
    A tuple of (doc_chunks, doc_id), where doc_chunks is a list of document chunks, each of which is a DocumentChunk object with an id, a document_id, a text, and a metadata attribute,
    and doc_id is the id of the document object, generated if not provided. The id of each chunk is generated from the document id and a sequential number, and the metadata is copied from the document object.
"""
function create_document_chunks(
    doc::Document, chunk_token_size=0
)::Tuple{Vector{DocumentChunk},String}
    # Generate a document id if not provided
    doc_id = !isnothing(doc.id) && !isempty(doc.id) ? doc.id : string(UUIDs.uuid4())

    # Check if the document text is empty or whitespace
    !isempty(doc.text) || return ([], doc_id)

    # Split the document text into chunks
    text_chunks = get_text_chunks(doc.text, chunk_token_size)

    metadata = DocumentChunkMetadata()
    if !isnothing(doc.metadata)
        for x in fieldnames(typeof(doc.metadata))
            setproperty!(metadata, x, getproperty(doc.metadata, x))
        end
    end

    metadata.document_id = doc_id

    # Initialize an empty list of chunks for this document
    doc_chunks = DocumentChunk[]

    # Assign each chunk a sequential number and create a DocumentChunk object
    for (i, text_chunk) in enumerate(text_chunks)
        chunk_id = "$(doc_id)_$(i)"
        doc_chunk = DocumentChunk(
            id=chunk_id,
            text=text_chunk,
            metadata=metadata,
        )
        # Append the chunk object to the list of chunks for this document
        push!(doc_chunks, doc_chunk)
    end
    # Return the list of chunks and the document id
    return doc_chunks, doc_id
end

"""
Convert a list of documents into a dictionary from document id to list of document chunks.

Args:
    documents: The list of documents to convert.
    chunk_token_size: The target size of each chunk in tokens, or None to use the default CHUNK_SIZE.

Returns:
    A dictionary mapping each document id to a list of document chunks, each of which is a DocumentChunk object
    with text, metadata, and embedding attributes.
"""
function get_document_chunks(
    documents::Vector{Document}, chunk_token_size=0
)::Dict{String,Vector{DocumentChunk}}
    # Initialize an empty dictionary of lists of chunks
    chunks = Dict{String,Vector{DocumentChunk}}()

    # Initialize an empty list of all chunks
    all_chunks = DocumentChunk[]

    # Loop over each document and create chunks
    for doc in documents
        doc_chunks, doc_id = create_document_chunks(doc, chunk_token_size)

        # Append the chunks for this document to the list of all chunks
        append!(all_chunks, doc_chunks)

        # Add the list of chunks for this document to the dictionary with the document id as the key
        chunks[doc_id] = doc_chunks
    end

    # Check if there are no chunks
    isempty(all_chunks) && return Dict()

    # Get all the embeddings for the document chunks in batches, using get_embeddings
    embeddings = Vector{Vector{Float32}}()
    for i in 1:EMBEDDINGS_BATCH_SIZE:length(all_chunks)
        # Get the text of the chunks in the current batch
        batch_texts = [
            chunk.text for chunk in all_chunks[i:min(end, i + EMBEDDINGS_BATCH_SIZE)]
        ]

        # Get the embeddings for the batch texts
        batch_embeddings = create_embeddings(batch_texts)

        # Append the batch embeddings to the embeddings list
        append!(embeddings, batch_embeddings)
    end

    # Update the document chunk objects with the embeddings
    for (i, chunk) in enumerate(all_chunks)
        # Assign the embedding from the embeddings list to the chunk object
        chunk.embedding = embeddings[i]
    end

    return chunks
end
