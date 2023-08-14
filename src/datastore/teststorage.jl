# Test storage module for logic check only
module TestStorageExt
using ..DataStore
using ..DataStore: AbstractStorage

using ...AppServer:
    DocumentChunk, 
    QueryWithEmbedding, QueryResult, 
    DocumentMetadataFilter, DocumentChunkWithScore,
    UpsertResponse

mutable struct TestStorage <: AbstractStorage
    data::Vector{String}

    TestStorage() = new([])
end
create_storage() = TestStorage()

function DataStore.upsert(
    storage::TestStorage,
    chunks::Dict{String, <:AbstractVector{DocumentChunk}},
)::UpsertResponse
    # add documents ids only into the storage-array
    ids = keys(chunks) |> collect
    append!(storage.data, ids)
    return UpsertResponse(ids = ids)
end

function DataStore.query(
    storage::TestStorage,
    queries::AbstractVector{QueryWithEmbedding},
)::Vector{QueryResult}
    isempty(storage.data) && return []

    # assume the query contains exact document id as we are storing
    # Otherwise, we need to implement a real mechanism for calculating embeddings. 
    return map(queries) do query_with_embedding
        text_query = query_with_embedding.query
        res = findfirst(s -> isequal(s, text_query), storage.data)

        QueryResult(
            query = text_query,
            results = isnothing(res) ? [] : [DocumentChunkWithScore(id = text_query, score = 1)],
        )
    end
end

function DataStore.delete(
    storage::TestStorage;
    filter::Vector{DocumentMetadataFilter},
)::Bool
    ids = getfield.(filter, :document_id)
    initial_length = length(storage.data)
    filter!(i -> i ∉ ids, storage.data)
    return initial_length != length(storage.data)
end

function DataStore.delete_all(storage::TestStorage)::Bool
    empty!(storage.data)
    return true
end

end
