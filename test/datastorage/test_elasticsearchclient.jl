
ENV["DATASTORE"] = "elasticsearch"
ENV["HNSW_DIMENSION"] = 10

using ElasticsearchClient

isdefined(Main, :ElasticsearchClient)

using GptSearchPlugin
using Test


