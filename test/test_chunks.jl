ENV["DATASTORE"] = "TEST"

using Test
using GptSearchPlugin
using Mocking

using OpenAI: create_embeddings

Mocking.activate()

text = "Respond with a JSON containing the extracted metadata in key value pairs."
chunk_size = 5

text_chunks = GptSearchPlugin.Server.get_text_chunks(text, chunk_size)

doc = GptSearchPlugin.Server.Document(text=text)
doc_chunks = GptSearchPlugin.Server.create_document_chunks(doc, chunk_size)

@test length(first(doc_chunks)) == length(text_chunks)

patch = @patch create_embeddings(api_key::String, text_vectors::AbstractVector) = (
    status=200,
    response=Dict(
        "data" => map(_ ->
                Dict(
                    "embedding" => rand(10),
                    "object" => "embedding",
                ),
            text_vectors
        )
    )
)
arr_chunks = apply(patch) do
    GptSearchPlugin.Server.get_document_chunks(repeat([doc], 5), chunk_size)
end

@test length(first(arr_chunks) |> values |> last) == length(text_chunks)

# @show first(arr_chunks)
