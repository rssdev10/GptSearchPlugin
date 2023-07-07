# CORS preflight headers that show what kinds of complex requests are allowed to API
const CORS_OPT_HEADERS = [
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Headers" => "*",
    "Access-Control-Allow-Methods" => "POST, GET, OPTIONS"
]

# CORS response headers that set access right of the recepient
const CORS_RES_HEADERS = ["Access-Control-Allow-Origin" => "*"]

function CorsMiddleware(handler)
    return function (req::HTTP.Request)
        if HTTP.method(req) == "OPTIONS"
            return HTTP.Response(200, CORS_OPT_HEADERS)
        else
            response = handler(req)
            append!(response.headers, CORS_RES_HEADERS)
            return response
        end
    end
end
