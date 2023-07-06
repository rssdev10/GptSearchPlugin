ENV["DATASTORE"] = "TEST"
using GptSearchPlugin
using Aqua

Aqua.test_all(GptSearchPlugin)
