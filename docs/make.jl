using Documenter
using GptSearchPlugin

makedocs(
    sitename = "GptSearchPlugin",
    format = Documenter.HTML(),
    modules = [GptSearchPlugin],
    pages = [
        "Home" => "index.md",
        "API" => "API/index.md",
        "Internals" => "Internals/index.md"
    ]
)

deploydocs(repo = "github.com/OpenSesame/GptSearchPlugin.git")
