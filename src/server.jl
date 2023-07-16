module AppServer

using HTTP

include("generated/src/GptPluginServer.jl")
using .GptPluginServer

include("services/embeddings.jl")
include("services/chunks.jl")

include("datastore/datastore.jl")

include("auth/auth.jl")
include("auth/cors.jl")

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

function get_static_files_and_paths()
    app_env = get(ENV, "APP_ENV", "dev")
    @info "Application environment is $app_env"

    static_path = ".well-known"
    abs_path = joinpath(@__DIR__, "..") |> normpath
    if !isequal(app_env, "prod")
        abs_path = joinpath(abs_path, "resources", "dev-openai", ".") |> normpath
    end
    local_path_position = lastindex(abs_path)
    well_known_path = joinpath(abs_path, static_path)
    static_files = filter(isfile, readdir(well_known_path, join=true))

    return (
        static_files=static_files,
        paths=map(static_files) do fn
            res = fn[local_path_position:end]

            @static Sys.iswindows() ? replace(res, '\\' => '/') : res
        end
    )
end

function run_server(; host="127.0.0.1", port=3333, base_url="")
    try
        static_files, domain_paths = get_static_files_and_paths()

        router = HTTP.Handlers.Router(
            HTTP.Handlers.default404,
            HTTP.Handlers.default405,
            get_auth_middleware(
                Set([
                    "/stop",
                    domain_paths...
                ])
            )
        )
        router = GptPluginServer.register(router, @__MODULE__; path_prefix=string(base_url))

        isinteractive() && HTTP.register!(router, "POST", "/stop", stop)
        HTTP.register!(router, "GET", "/ping", ping)

        for (abs_path, d_path) in zip(static_files, domain_paths)
            HTTP.register!(router, "GET", d_path, _ -> HTTP.Response(200, read(abs_path)))
        end
        server[] = HTTP.serve!(router |> CorsMiddleware, host, port, verbose=false)
        wait(server[])
    catch ex
        @error("Server error", exception = (ex, catch_backtrace()))
    end
end

end

# AppServer.run_server()
