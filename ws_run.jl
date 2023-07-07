#!/usr/bin/env julia --project=@.

doc = """Web service starter

Usage:
  $(Base.basename(@__FILE__)) [--port=<num>] [--base_url=<url>] [--bind=<ip>]

Options:
  -h --help         Show this screen
  -p, --port=<num>  Port  [default: 3333]
  -b, --bind=<ip>   Bind address [default: 0.0.0.0]
  --base_url=<url>  Additional URL prefix for the service [default: /]

"""

using DocOpt  # import docopt function
using Pkg

args = docopt(doc, version = Pkg.project().version)
#@info args

using Sockets

function get_env_or(name::String, or_value)
    if haskey(ENV, name)
        @info("Using ENV $(name) value: $(ENV[name])")
        ENV[name]
    else
        or_value
    end
end

BASE_URL = get_env_or("BASE_URL", args["--base_url"])
HOST = Sockets.getaddrinfo(get_env_or("HOST", args["--bind"]))
PORT = parse(Int, get_env_or("PORT", args["--port"]))

app_server = Pkg.project().name
@info "Activating web service..."
@eval using $(Symbol(app_server))
m = getfield(Main, Symbol(app_server))

# endswith(PROGRAM_FILE, basename(@__FILE__)) && start_server()
m.AppServer.run_server(host = string(HOST), port = PORT, base_url = BASE_URL)
