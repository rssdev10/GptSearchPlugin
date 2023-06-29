test_index_name = "test_gpt_plugin_chunks_index"

ENV["DATASTORE"] = "elasticsearch"
ENV["CHUNKS_INDEX_NAME"] = test_index_name
ENV["KNN_DIMENSION"] = 10

using ElasticsearchClient
using GptSearchPlugin
using GptSearchPlugin.Server.DataStore
using Test
using Mocking
using OpenAI: create_embeddings

Mocking.activate()

total_docs_in_index(storage) =
  ElasticsearchClient.search(
    storage.client,
    index=test_index_name
  ).body["hits"]["total"]["value"]

storage = DataStore.STORAGE

DataStore.delete_all(storage)
@test total_docs_in_index(storage) == 0

text = "Respond with a JSON containing the extracted metadata in key value pairs."

chunk_size = 4
doc = GptSearchPlugin.Server.Document(text=text)
patch = @patch create_embeddings(api_key::String, text_vectors) = map(_ -> rand(10), text_vectors)
arr_chunks = apply(patch) do
    GptSearchPlugin.Server.get_document_chunks(repeat([doc], 10), chunk_size)
end
chunks_count = values(arr_chunks) |> Iterators.flatten |> collect |> length

document_ids = DataStore.upsert(
  storage,
  arr_chunks
)
@test length(document_ids) == length(arr_chunks)
@test all(in(document_ids), keys(arr_chunks))
@test total_docs_in_index(storage) == chunks_count

query_with_emb = GptSearchPlugin.Server.QueryWithEmbedding(
  query = "Some query",
  embedding = rand(10)
)

query_results = DataStore.query(
  storage,
  [query_with_emb]
)
@test length(first(query_results).results) == query_with_emb.top_k
@test first(query_results).query == query_with_emb.query

doc_ids_for_delete = rand(document_ids, 2)

@test DataStore.delete(
  storage,
  filter=map(
    doc_id -> GptSearchPlugin.Server.DocumentMetadataFilter(document_id=doc_id),
    doc_ids_for_delete
  )
)
@test total_docs_in_index(storage) == chunks_count - 10
