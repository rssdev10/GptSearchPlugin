using Mocking

using OpenAI: create_embeddings

Mocking.activate()

patch = @patch create_embeddings(api_key::String, text_vectors::AbstractVector) = (
    status = 200,
    response = Dict(
        "data" => map(_ ->
                Dict(
                    "embedding" => rand(10),
                    "object" => "embedding",
                ),
            text_vectors,
        ),
    ),
)
