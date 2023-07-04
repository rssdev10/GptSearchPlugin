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
    DocumentMetadataFilter, DocumentChunkWithScore,
    UpsertResponse

const DEFAULT_CHUNKS_INDEX_NAME = "gpt_plugin_chunks_knn_index"
const CHUNKS_INDEX_SCHEMA_FILE_PATH =
    joinpath(@__DIR__, "es_settings", "chunks_index_schema.json")

const DEFAULT_KNN_DIMENSION = 1536
const DEFAULT_KNN_SIMILARITY = "cosine"
const DEFAULT_NUM_CANDIDATES = 10_000

struct ElasticsearchStorage <: AbstractStorage
    client::ElasticsearchClient.Client
    chunks_index_name::AbstractString

    function ElasticsearchStorage(client::ElasticsearchClient.Client)
        index_name = chunks_index_name()

        if !ElasticsearchClient.Indices.exists(client, index=index_name)
            index_settings_template =
                read(CHUNKS_INDEX_SCHEMA_FILE_PATH) |>
                String |>
                Mustache.parse

            index_settings = index_settings_template(
                dimension=knn_dimension(),
                similarity=knn_similarity()
            ) |> JSON.parse

            try
                ElasticsearchClient.Indices.create(client, index=index_name, body=index_settings)
            catch e
                @error e
            end
        end

        new(client, index_name)
    end
end

chunks_index_name() = get(ENV, "CHUNKS_INDEX_NAME", DEFAULT_CHUNKS_INDEX_NAME)
knn_dimension() = get(ENV, "KNN_DIMENSION", DEFAULT_KNN_DIMENSION)
knn_similarity() = get(ENV, "KNN_SIMILARITY", DEFAULT_KNN_SIMILARITY)

"""
Takes in a list of list of document chunks and inserts them into the database.

Return a list of document ids.
"""
function DataStore.upsert(
    storage::ElasticsearchStorage,
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

    ElasticsearchClient.bulk(storage.client, index=storage.chunks_index_name, body=index_batch)
    ElasticsearchClient.Indices.refresh(storage.client, index=storage.chunks_index_name)

    UpsertResponse(collect(keys(chunks)))
end

"""
Takes in a list of queries with embeddings and filters and 
returns a list of query results with matching document chunks and scores.
"""
function DataStore.query(
    storage::ElasticsearchStorage,
    queries::AbstractVector{QueryWithEmbedding}
)::Vector{QueryResult}
    query_tasks = map(query_with_emb -> single_query(storage, query_with_emb), queries)
    
    map(query_tasks) do (query, query_task)
        wait(query_task)

        response = query_task.result
        results =
            map(response.body["hits"]["hits"]) do hit
                source = hit["_source"]

                metadata = DocumentChunkMetadata(
                    document_id=source["metadata"]["document_id"]
                )

                DocumentChunkWithScore(;
                    id=hit["_id"],
                    text=source["text"],
                    metadata=metadata,
                    embedding=source["embedding"],
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
    storage::ElasticsearchStorage,
    query::QueryWithEmbedding
)::Tuple{QueryWithEmbedding,Task}
    
    knn_query = Dict(
        :knn => Dict(
            :field => :embedding,
            :query_vector => query.embedding,
            :num_candidates => DEFAULT_NUM_CANDIDATES,
            :k => query.top_k
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
        knn_query[:knn][:filter] = [nested_document_filter]
    end

    task = @async ElasticsearchClient.search(
        storage.client,
        index=storage.chunks_index_name, 
        body=knn_query
    )

    (query, task)
end

"""
Removes vectors by ids, filter.
Multiple parameters can be used at once.

Returns whether the operation was successful.
"""
function DataStore.delete(
    storage::ElasticsearchStorage;
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
        body=query
    )

    response.status == 200
end

"""
Removes everything in the datastore

Returns whether the operation was successful.
"""
function DataStore.delete_all(storage::ElasticsearchStorage)::Bool
    query = Dict(:query => Dict(:match_all => Dict()))

    response = ElasticsearchClient.delete_by_query(
        storage.client,
        index=storage.chunks_index_name,
        body=query
    )

    response.status == 200
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
