
using Pkg
datastore_env() = get(ENV, "DATASTORE", "")

const DATASTORE_MODULE = Ref{Module}()

begin
    datastore = datastore_env() |> uppercase

    @info string("Requested datastore: ", datastore_env())

    # workaround to detect running in test mode
    if isnothing(Pkg.project().name)
        datastore = "TEST"
    end

    global DATASTORE_MODULE[] = if isequal(datastore, "ELASTICSEARCH")
        @info "Pluging ElasticsearchClientExt"
        include("../../ext/ElasticsearchClientExt/ElasticsearchClientExt.jl")

        ElasticsearchClientExt
    elseif isequal(datastore, "OPENSEARCH")
        @info "Pluging OpenSearchExt"
        include("../../ext/OpenSearchExt/OpenSearchExt.jl")
        
        OpenSearchExt
    elseif isequal(datastore, "TEST")
        @info "Dummy storage for the logic check only"
        include("teststorage.jl")

        TestStorageExt
    else
        error("DATASTORE environment variable must be non empty and valid")
    end
end

function get_datastore()::Union{AbstractStorage,Nothing}
    global DATASTORE_MODULE
    isassigned(DATASTORE_MODULE) || error("DATASTORE environment variable must be non empty and valid")

    DATASTORE_MODULE[].create_storage()
end
