module ElasticsearchClientExt

using ElasticsearchClient
using Mustache
using JSON
using Mocking

using ..DataStore
using ..DataStore: AbstractStorage
using ...Server
using ...Server:
    DocumentChunk, DocumentChunkMetadata, 
    QueryWithEmbedding, QueryResult, 
    DocumentMetadataFilter

const CHUNKS_INDEX_NAME = "gpt_plugin_chunks_knn_index"
const CHUNKS_INDEX_SCHEMA_FILE_PATH =
    joinpath(@__DIR__, "..", "es_settings", "chunks_index_schema.json")

const DEFAULT_KNN_DIMENSION = 1536
const DEFAULT_KNN_SIMILARITY = "dot_product"

struct ElasticsearchStorage <: AbstractStorage
    client::ElasticsearchClient.Client

    function ElasticsearchStorage(client::ElasticsearchClient.Client)
        if !ElasticsearchClient.Indices.exists(client, index=CHUNKS_INDEX_NAME)
            index_settings_template =
                read(CHUNKS_INDEX_SCHEMA_FILE_PATH) |>
                String |>
                Mustache.parse

            index_settings = index_settings_template(
                dimension=knn_dimension(),
                similarity=knn_similarity()
            ) |> JSON.parse

            try
                ElasticsearchClient.Indices.create(client, index=CHUNKS_INDEX_NAME, body=index_settings)
            catch e
                @error e
            end
        end

        new(client)
    end
end

knn_dimension() = get(ENV, "KNN_DIMENSION", DEFAULT_KNN_DIMENSION)
knn_similarity() = get(ENV, "KNN_SIMILARITY", DEFAULT_KNN_SIMILARITY)

"""
Takes in a list of list of document chunks and inserts them into the database.

Return a list of document ids.
"""
function DataStore.upsert(
    storage::ElasticsearchStorage,
    chunks::Dict{String,<:AbstractVector{DocumentChunk}}
)::Vector{<:AbstractString}
    index_batch = AbstractDict[]

    for doc_chunks in values(chunks), doc_chunk in doc_chunks
        operation_name = :index
        operation_body = Dict(
            :_id => doc_chunk.id
            :data => Dict(
                :text => doc_chunk.text,
                :metadata => doc_chunk.metadata,
                :embedding => doc_chunk.embedding
            )
        )

        push!(index_batch, Dict(operation_name => operation_body))
    end

    ElasticsearchClient.bulk(storage.client, index=CHUNKS_INDEX_NAME, body=index_batch)
end

"""
Takes in a list of queries with embeddings and filters and 
returns a list of query results with matching document chunks and scores.
"""
function DataStore.query(
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
function DataStore.delete(
    storage::ElasticsearchStorage,
    ids::AbstractVector{String};
    filter::Union{Vector{DocumentMetadataFilter},Nothing}=nothing
)::Bool
    should_conds = AbstractDict[
        Dict(
            :ids => Dict(:values => ids)
        )
    ]

    if !isnothing(filter)
        document_ids = getproperty.(filter, :document_id)
        push!(
            should_conds,
            Dict(
                :terms => Dict( "metadata.document_id" => document_ids)
            )
        )
    end

    query = Dict(
        :query => Dict(
            :bool => Dict(
                :should => should_conds
            )
        )
    )
    response = ElasticsearchClient.delete_by_query(storage.client, index=CHUNKS_INDEX_NAME, body=query)

    response.status == 200
end

"""
Removes everything in the datastore

Returns whether the operation was successful.
"""
function DataStore.delete_all(storage::ElasticsearchStorage)
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
