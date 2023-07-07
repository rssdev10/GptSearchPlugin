ENV["DATASTORE"] = "TEST"

using GptSearchPlugin
using Test

ENV["APP_ENV"]="prod"
p_static_files, p_domain_paths = GptSearchPlugin.AppServer.get_static_files_and_paths()

delete!(ENV, "APP_ENV")
static_files, domain_paths = GptSearchPlugin.AppServer.get_static_files_and_paths()

check_list = Set(["/.well-known/ai-plugin.json", "/.well-known/logo.png", "/.well-known/openapi.yaml"])

filter_paths(paths) = filter(fn -> fn in check_list, paths) |> sort

@test filter_paths(p_domain_paths) == filter_paths(domain_paths)
@test filter_paths(domain_paths) |> length == length(check_list)
