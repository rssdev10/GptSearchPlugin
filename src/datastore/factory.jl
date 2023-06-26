
isdefined(Main, :ElasticsearchClient) && include("../../ext/ElasticsearchClientExt.jl")

function get_datastore()::Union{AbstractStorage,Nothing}
    datastore = get(ENV, "DATASTORE", nothing)
    isnothing(datastore) && error("DATASTORE environment variable must be non empty")

    return if isequal(uppercase(datastore), "ELASTICSEARCH")
        ElasticsearchClientExt.create_storage()
    else
        nothing
    end
end
