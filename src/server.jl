module Server

using HTTP

include("generated/src/GptPluginServer.jl")
using .GptPluginServer

include("services/embeddings.jl")
include("services/chunks.jl")

include("datastore/datastore.jl")

const server = Ref{Any}(nothing)

"""
- *invocation:* POST /query
"""
function query_query_post(req::HTTP.Request, query_request::QueryRequest;)::QueryResponse
    try
        return QueryResponse(
            results=DataStore.query(query_request.queries)
        )
    catch e
        showerror(stderr, e)
        display(stacktrace(catch_backtrace()))
        throw(e)
        # return HTTP.Response(500, "Internal server error")
    end
end

"""
- *invocation:* POST /upsert
"""
function upsert_post(req::HTTP.Request; upsert_request=nothing)::UpsertResponse
    documents = upsert_request.documents

    if isa(documents, AbstractVector)
        doc_ids = DataStore.upsert(documents)

        isempty(doc_ids.ids) || return doc_ids
    end

    return HTTP.Response(500, "Internal server error")
end

function stop(::HTTP.Request)
    HTTP.close(server[])
    return HTTP.Response(200, "")
end

function ping(::HTTP.Request)
    return HTTP.Response(200, "")
end

function run_server(port=3333)
    try
        router = HTTP.Router()
        router = GptPluginServer.register(router, @__MODULE__; path_prefix="")
        HTTP.register!(router, "POST", "/stop", stop)
        HTTP.register!(router, "GET", "/ping", ping)
        server[] = HTTP.serve!(router, port)
        wait(server[])
    catch ex
        @error("Server error", exception = (ex, catch_backtrace()))
    end
end

end

# Server.run_server()
