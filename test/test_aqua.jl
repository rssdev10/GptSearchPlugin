ENV["DATASTORE"] = "test"
using GptSearchPlugin
using Aqua

Aqua.test_all(GptSearchPlugin)
