
datastore_env() = get(ENV, "DATASTORE", "")

global DATASTORE_MODULE = nothing

if isequal(uppercase(datastore_env()), "ELASTICSEARCH")
    @info "Pluging ElasticsearchClientExt"
    include("../../ext/ElasticsearchClientExt/ElasticsearchClientExt.jl")

    DATASTORE_MODULE = ElasticsearchClientExt
end

function get_datastore()::Union{AbstractStorage,Nothing}
    isnothing(DATASTORE_MODULE) && error("DATASTORE environment variable must be non empty and valid")

    DATASTORE_MODULE.create_storage()
end
