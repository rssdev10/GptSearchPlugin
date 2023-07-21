module OpenSearchExt

include("OpenSearchAuth.jl")

using ElasticsearchClient

using Mustache
using JSON
using Mocking
using AWS
using Dates

using ..DataStore
using ..DataStore: AbstractStorage
using ...AppServer
using ...AppServer:
    DocumentChunk, DocumentChunkMetadata, 
    QueryWithEmbedding, QueryResult, 
    DocumentMetadataFilter, DocumentChunkWithScore,
    UpsertResponse  

const DEFAULT_CHUNKS_INDEX_NAME = "gpt_plugin_chunks_knn_index"
const CHUNKS_INDEX_SCHEMA_FILE_PATH =
    joinpath(@__DIR__, "es_settings", "chunks_index_schema.json")

const DEFAULT_KNN_DIMENSION = 1536
const DEFAULT_KNN_SPACE_TYPE = "cosinesimil"
const DEFAULT_KNN_EF_CONSTRUCTION = 512
const DEFAULT_KNN_M = 16
const DEFAULT_KNN_EF_SEARCH = 512
const DEFAULT_NUM_CANDIDATES = 10_000

struct OpensearchStorage <: AbstractStorage
    client::ElasticsearchClient.Client
    local_storage::Bool
    chunks_index_name::AbstractString

    function OpensearchStorage(client::ElasticsearchClient.Client, local_storage::Bool)
        index_name = chunks_index_name()

        if !ElasticsearchClient.Indices.exists(client, index=index_name, auth_params=get_auth_params(local_storage))
            index_settings_template =
                read(CHUNKS_INDEX_SCHEMA_FILE_PATH) |>
                String |>
                Mustache.parse

            index_settings = index_settings_template(
                dimension=knn_dimension(),
                space_type=knn_space_type(),
                ef_construction=knn_ef_construction(),
                m=knn_m(),
                ef_search=knn_ef_search()
            ) |> JSON.parse

            try
                ElasticsearchClient.Indices.create(
                    client,
                    index=index_name,
                    body=index_settings,
                    auth_params=get_auth_params(local_storage)
                )
            catch e
                @error e
            end
        end

        new(client, local_storage, index_name)
    end
end

chunks_index_name() = get(ENV, "CHUNKS_INDEX_NAME", DEFAULT_CHUNKS_INDEX_NAME)
knn_dimension() = get(ENV, "KNN_DIMENSION", DEFAULT_KNN_DIMENSION)
knn_space_type() = get(ENV, "KNN_SPACE_TYPE", DEFAULT_KNN_SPACE_TYPE)
knn_ef_construction() = get(ENV, "KNN_EF_CONSTRUCTION", DEFAULT_KNN_EF_CONSTRUCTION)
knn_m() = get(ENV, "KNN_M", DEFAULT_KNN_M)
knn_ef_search() = get(ENV, "KNN_EF_SEARCH", DEFAULT_KNN_EF_SEARCH)

struct AuthParams
    creds::AWSCredentials
    expires_at::DateTime

    function AuthParams()
        # ttl in seconds, 1 hour by default
        ttl = get(ENV, "AUTH_PARAMS_TTL", 3600)

        new(
            AWSCredentials(),
            now() + Second(ttl)
        )
    end
end
global CURRENT_AUTH_PARAMS::Union{Nothing,Ref{AWSCredentials}} = nothing

"""
Takes in a list of list of document chunks and inserts them into the database.

Return a list of document ids.
"""
function DataStore.upsert(
    storage::OpensearchStorage,
    chunks::Dict{String,<:AbstractVector{DocumentChunk}}
)::UpsertResponse
    index_batch = AbstractDict[]

    for doc_chunks in values(chunks), doc_chunk in doc_chunks
        operation_name = :index
        operation_body = Dict(
            :_id => doc_chunk.id,
            :data => Dict(
                :text => doc_chunk.text,
                :metadata => doc_chunk.metadata,
                :embedding => doc_chunk.embedding
            )
        )

        push!(index_batch, Dict(operation_name => operation_body))
    end

    ElasticsearchClient.bulk(storage.client, index=storage.chunks_index_name, body=index_batch, auth_params=get_auth_params(storage))
    ElasticsearchClient.Indices.refresh(storage.client, index=storage.chunks_index_name, auth_params=get_auth_params(storage))

    UpsertResponse(collect(keys(chunks)))
end

"""
Takes in a list of queries with embeddings and filters and 
returns a list of query results with matching document chunks and scores.
"""
function DataStore.query(
    storage::OpensearchStorage,
    queries::AbstractVector{QueryWithEmbedding}
)::Vector{QueryResult}
    query_tasks = map(query_with_emb -> single_query(storage, query_with_emb), queries)
    
    map(query_tasks) do (query, query_task)
        wait(query_task)

        response = query_task.result
        results =
            map(response.body["hits"]["hits"]) do hit
                source = hit["_source"]

                stored_metadata = source["metadata"]
                metadata = DocumentChunkMetadata(
                    source=get(stored_metadata, "source", nothing),
                    source_id=get(stored_metadata, "source_id", nothing),
                    url=get(stored_metadata, "url", nothing),
                    created_at=get(stored_metadata, "created_at", nothing),
                    author=get(stored_metadata, "author", nothing),
                    document_id=get(stored_metadata, "document_id", nothing),
                )

                DocumentChunkWithScore(;
                    id=hit["_id"],
                    text=source["text"],
                    metadata=metadata,
                    # embedding=source["embedding"], # not required for ChatGPT
                    score=hit["_score"]
                )
            end

        QueryResult(;
            query=query.query,
            results=results
        )
    end
end

function single_query(
    storage::OpensearchStorage,
    query::QueryWithEmbedding
)::Tuple{QueryWithEmbedding,Task}
    knn_query = Dict(
        :knn => Dict(
            :embedding => Dict(
                :vector => query.embedding,
                :k => query.top_k
            )    
        )
    )

    full_query = Dict(
        :query => Dict(
            :bool => Dict(
                :must => [knn_query]
            )
        )
    )

    if !isnothing(query.filter)
        nested_document_filter = Dict(
            :nested => Dict(
                :path => :metadata,
                :query => Dict(
                    :term => Dict(
                        "metadata.document_id" => query.filter.document_id
                    )
                )
            )
        )
        full_query[:query][:bool][:filter] = [nested_document_filter]
    end

    task = @async ElasticsearchClient.search(
        storage.client,
        index=storage.chunks_index_name, 
        body=full_query,
        auth_params=get_auth_params(storage)
    )

    (query, task)
end

"""
Removes vectors by ids, filter.
Multiple parameters can be used at once.

Returns whether the operation was successful.
"""
function DataStore.delete(
    storage::OpensearchStorage;
    filter::Vector{DocumentMetadataFilter}
)::Bool
    document_ids = getproperty.(filter, :document_id)
    query = Dict(
        :query => Dict(
            :nested => Dict(
                :path => "metadata",
                :query => Dict(
                    :terms => Dict(
                        "metadata.document_id" => document_ids
                    )
                )
            )
        )
    )
    response = ElasticsearchClient.delete_by_query(
        storage.client,
        index=storage.chunks_index_name,
        body=query,
        auth_params=get_auth_params(storage)
    )

    response.status == 200
end

"""
Removes everything in the datastore

Returns whether the operation was successful.
"""
function DataStore.delete_all(storage::OpensearchStorage)::Bool
    query = Dict(:query => Dict(:match_all => Dict()))

    response = ElasticsearchClient.delete_by_query(
        storage.client,
        index=storage.chunks_index_name,
        body=query,
        auth_params=get_auth_params(storage)
    )

    response.status == 200
end

function create_storage()
    local_storage = get(ENV, "LOCAL_STORAGE", true)
    if local_storage
        OpensearchStorage(
            ElasticsearchClient.Client(
                host=(
                    host=get(ENV, "ES_HOST", "localhost"),
                    port=get(ENV, "ES_PORT", "9200") |> str -> parse(Int16, str),
                    scheme="http"
                )
            ),
            local_storage
        )
    else
        es_host = get(ENV, "ES_HOST", nothing)

        isnothing(es_host) && throw(ArgumentError("Environment variable ES_HOST must be set"))

        OpensearchStorage(
            ElasticsearchClient.Client(
                host=(host=es_host, port=443, scheme="https"),
                http_client=OpenSearchAuth
            ),
            local_storage
        )
    end
end

function get_auth_params(local_storage::Bool)
    local_storage && return

    if isnothing(CURRENT_AUTH_PARAMS) || now() > CURRENT_AUTH_PARAMS.x.expires_at
        refresh_auth_params()
    end

    CURRENT_AUTH_PARAMS.x
end
get_auth_params(storage::OpensearchStorage) = get_auth_params(storage.local_storage)

function refresh_auth_params()
    global CURRENT_AUTH_PARAMS = Ref(AuthParams())
end

end
