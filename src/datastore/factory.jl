
using Pkg
datastore_env() = get(ENV, "DATASTORE", "")

global DATASTORE_MODULE = let
    datastore = datastore_env() |> uppercase

    # workaround to detect running in test mode
    if isnothing(Pkg.project().name)
        datastore = "TEST"
    end

    if isequal(datastore, "ELASTICSEARCH")
        @info "Pluging ElasticsearchClientExt"
        include("../../ext/ElasticsearchClientExt/ElasticsearchClientExt.jl")

        ElasticsearchClientExt
    elseif isequal(datastore, "TEST")
        TestStorageExt
    else
        nothing
    end
end
using Pkg
function get_datastore()::Union{AbstractStorage,Nothing}
    isnothing(DATASTORE_MODULE) && error("DATASTORE environment variable must be non empty and valid")

    DATASTORE_MODULE.create_storage()
end
