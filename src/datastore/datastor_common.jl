using ..GptPluginServer

abstract type AbstractStorage end

include("teststorage.jl")

"""
Takes in a list of list of document chunks and inserts them into the database.

Return a list of document ids.
"""
function upsert(
    storage::AbstractStorage,
    chunks::Dict{String,<:AbstractVector{DocumentChunk}}
)::UpsertResponse
    error("The method 'upsert' is not implemeted for $(typeof(storage))")
end

"""
Takes in a list of queries with embeddings and filters and 
returns a list of query results with matching document chunks and scores.
"""
function query(
    storage::AbstractStorage,
    queries::AbstractVector{QueryWithEmbedding}
)::Vector{QueryResult}
    error("The method 'query' is not implemeted for $(typeof(storage))")
end

"""
Removes vectors by ids, filter.
Multiple parameters can be used at once.

Returns whether the operation was successful.
"""
function delete(
    storage::AbstractStorage;
    filter::Vector{DocumentMetadataFilter}
)::Bool
    error("The method 'delete' is not implemeted for $(typeof(storage))")
end

"""
Removes everything in the datastore

Returns whether the operation was successful.
"""
function delete_all(storage::AbstractStorage)
    error("The method 'delete_all' is not implemeted for $(typeof(storage))")
end
