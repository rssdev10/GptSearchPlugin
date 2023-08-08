ENV["DATASTORE"] = "TEST"

using Test
using GptSearchPlugin
using Mocking

using OpenAI: create_embeddings

Mocking.activate()

text = "Respond with a JSON containing the extracted metadata in key value pairs."
chunk_size = 5

text_chunks = GptSearchPlugin.AppServer.get_text_chunks(text, chunk_size)

doc = GptSearchPlugin.AppServer.Document(text = text)
doc_chunks = GptSearchPlugin.AppServer.create_document_chunks(doc, chunk_size)

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
	GptSearchPlugin.AppServer.get_document_chunks(repeat([doc], 5), chunk_size)
end

@test length(first(arr_chunks) |> values |> last) == length(text_chunks)

# @show first(arr_chunks)

texts = [
	"А теперь проверим двухбайтовые символы.",
	# test 3-bytes unicode chunking
	"保留和晋升不应使任何团体或个人处于不利地位。",
	"특히 직장에서 변화를 만나게 되면 부정하게 되기가 쉽습니다.",
]
for text in texts
	arr_chunks = apply(patch) do
		doc = GptSearchPlugin.AppServer.Document(text = text)
		GptSearchPlugin.AppServer.get_document_chunks([doc], 10) #chunk_size * 3)
	end

	@test !isempty(arr_chunks)

	recovered_str = map(x -> x.text, first(arr_chunks) |> values |> last) |> join
    @show recovered_str

	@test text[begin] == recovered_str[begin]
	@test text[end] == recovered_str[end]
end
