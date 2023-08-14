ENV["DATASTORE"] = "TEST"

using Test
using HTTP

using GptSearchPlugin

include("helpers/mocking.jl")

apply(patch) do
    req = HTTP.Messages.Request()

    # Create a set of empty documents with known ids.
    documents = map(1:10) do id
        GptSearchPlugin.AppServer.Document(
            id = string(id),
            text = "Some document text $id",
        )
    end

    upsert_request = GptSearchPlugin.AppServer.UpsertRequest(
        documents = documents,
    )
    upsert_response = GptSearchPlugin.AppServer.upsert_post(req, upsert_request)

    @test !isnothing(upsert_response) && !isnothing(upsert_response.ids)
    @test isempty(intersect(documents, upsert_response.ids))

    # Check that we have a document in a storage with a known id.
    # Suggest we have a dummy storage where we search by id only, without embedding.
    query_doc_id = string(last(documents).id)
    query_request = GptSearchPlugin.AppServer.QueryRequest(
        queries = [GptSearchPlugin.AppServer.Query(query = query_doc_id)]
    )
    query_response = GptSearchPlugin.AppServer.query_post(req, query_request)

    @test !isnothing(query_response) && !isnothing(query_response.results) && !isempty(query_response.results)
    query_result = first(query_response.results)
    @test !isempty(query_result.results) && isequal(first(query_result.results).id, query_doc_id)

    # Delete some documents.
    request = GptSearchPlugin.AppServer.DeleteRequest(
        ids = [query_doc_id]
    )
    delete_response = GptSearchPlugin.AppServer.delete_docs(req, request)
    @test !isnothing(delete_response) && delete_response.success

    # Delete all documents.
    request = GptSearchPlugin.AppServer.DeleteRequest(
        delete_all = true
    )
    delete_response = GptSearchPlugin.AppServer.delete_docs(req, request)
    @test !isnothing(delete_response) && delete_response.success

    # Finally check that we have nothing.
    query_response = GptSearchPlugin.AppServer.query_post(req, query_request)
    @test !isnothing(query_response) && !isnothing(query_response.results) && isempty(query_response.results)
end
