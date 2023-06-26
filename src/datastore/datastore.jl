module DataStore

using Mocking

include("datastor_common.jl")
include("factory.jl")

STORAGE = nothing

"""
Takes in a list of documents and inserts them into the database.
First deletes all the existing vectors with the document id (if necessary, depends on the vector db), 
then inserts the new ones.

Return a list of document ids.
"""
function upsert(documents::AbstractVector{Document}; chunk_token_size=0)::Vector{String}
    @assert !isnothing(STORAGE) "Storage is not initialized"

    delete(
        STORAGE,
        documents,
        filter=map(
            document -> DocumentMetadataFilter(document_id=document.id),
            documents
        )
    )

    chunks = get_document_chunks(documents, chunk_token_size)

    return upsert(STORAGE, chunks)
end

"""
Takes in a list of queries and filters and returns a list of query results with matching document chunks and scores.
"""
function query(queries::AbstractVector{Query})::Vector{QueryResult}
    @assert !isnothing(STORAGE) "Storage is not initialized"

    # get a list of of just the queries from the Query list
    query_texts = [query.query for query in queries]
    query_embeddings = @mock create_embeddings(OPENAI_API_KEY, query_texts)

    # hydrate the queries with embeddings
    queries_with_embeddings = map(zip(queries, query_embeddings)) do query, embedding
        query_we = QueryWithEmbedding(embedding=embedding)
        for x in fieldnames(typeof(query))
            query_we[x] = query[x]
        end
        query_we
    end
    return query(STORAGE, queries_with_embeddings)
end

function __init__()
    global STORAGE = get_datastore()
end
end
