module Server

using HTTP

OPENAI_API_KEY = get(ENV, "OPENAI_API_KEY", "")

include("generated/src/GptPluginServer.jl")
using .GptPluginServer

include("services/chunks.jl")

include("datastore/datastore.jl")

const server = Ref{Any}(nothing)

"""
- *invocation:* POST /query
"""
function query_query_post(req::HTTP.Request, query_request::QueryRequest;)::QueryResponse
    try
        return QueryResponse(results=
        DataStore.query(query_request.queries)
        )
    catch e
        @error e
        return HTTP.Response(500, "Internal server error")
    end
end

"""
- *invocation:* POST /upsert
"""
function upsert_post(req::HTTP.Request; documents=nothing)::Vector{<:AbstractString}
    if isa(document, Vector)
        doc_ids = DataStore.upsert(documents)

        isempty(doc_ids) || return doc_ids
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

function run_server(port=8080)
    try
        router = HTTP.Router()
        router = GptPluginServer.register(router, @__MODULE__; path_prefix="/v2")
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
