ENV["DATASTORE"] = "test"

using Test
using GptSearchPlugin
using HTTP

# see https://jwt.io/ to create your own token
jwt_bearer = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"

ENV["BEARER_TOKEN"] = "" # no auth

auth_handler = GptSearchPlugin.Server.get_auth_middleware(Set(["/stop"]))
@test isnothing(auth_handler)

ENV["BEARER_TOKEN"] = jwt_bearer
auth_handler = GptSearchPlugin.Server.get_auth_middleware(Set(["/stop"]))
@test !isnothing(auth_handler)

http_req_no_auth = HTTP.Messages.Request()
http_req_no_auth.target = "/stop"
@test auth_handler(_ -> true)(http_req_no_auth)

http_req_no_auth.target = "/query"

http_req_auth = HTTP.Messages.Request()
http_req_auth.target = "/query"
@test auth_handler(_ -> true)(http_req_auth).status == 401

push!(http_req_auth.headers, Pair("Authorization", "Bearer $jwt_bearer"))
@test auth_handler(_ -> true)(http_req_auth)
