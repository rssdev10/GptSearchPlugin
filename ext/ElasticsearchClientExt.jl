module ElasticsearchClientExt

using ElasticsearchClient

using .GptSearchPlugin
using .GptSearchPlugin.DataStore

struct ElasticsearchStorage <: AbstractStorage
    client::ElasticsearchClient
end

"""
Takes in a list of list of document chunks and inserts them into the database.

Return a list of document ids.
"""
function GptSearchPlugin.DataStore.upsert(
    storage::ElasticsearchStorage,
    chunks:Dict{String,<:AbstractVector{DocumentChunk}}
)::Vector{String}
    error("The method 'upsert' is not implemeted for $(typeof(storage))")
end

"""
Takes in a list of queries with embeddings and filters and 
returns a list of query results with matching document chunks and scores.
"""
function GptSearchPlugin.DataStore.query(
    storage::ElasticsearchStorage,
    queries::AbstractVector{QueryWithEmbedding}
)::Vector{QueryResult}
    error("The method 'query' is not implemeted for $(typeof(storage))")
end

"""
Removes vectors by ids, filter.
Multiple parameters can be used at once.

Returns whether the operation was successful.
"""
function GptSearchPlugin.DataStore.delete(
    storage::ElasticsearchStorage,
    ids::AbstractVector{String};
    filter::Union{Vector{DocumentMetadataFilter},Nothing}=nothing
)::Bool
    error("The method 'delete' is not implemeted for $(typeof(storage))")
end

"""
Removes everything in the datastore

Returns whether the operation was successful.
"""
function GptSearchPlugin.DataStore.delete_all(storage::ElasticsearchStorage)
    error("The method 'delete_all' is not implemeted for $(typeof(storage))")
end

create_storage() = ElasticsearchStorage(
    ElasticsearchClient.Client(
        host=(
            host=get(ENV, "ES_HOST", "localhost"),
            port=get(ENV, "ES_PORT", "9200") |> str -> parse(Int16, str),
            scheme="http"
        )
    )
)

end
