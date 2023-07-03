using OpenAI

using DebugDataWriter
using Mocking

OPENAI_API_KEY = get(ENV, "OPENAI_API_KEY", "")


const EMPTY_EMBEDDING_RESULT = Float64[]
const EMPTY_BATCH_EMBEDDING_RESULT = Vector{Float64}[]

function create_embeddings(batch_texts::Vector{<:AbstractString})::Vector{Vector{Float64}}
    response = @mock OpenAI.create_embeddings(OPENAI_API_KEY, batch_texts)
    result = EMPTY_BATCH_EMBEDDING_RESULT

    @debug_output get_debug_id("batch_embeddings") "OpenAI" response

    response.status != 200 && return result

    if (v = get(response.response, "data", nothing)) isa AbstractVector
        result = map(v) do data
            get(data, "embedding", EMPTY_EMBEDDING_RESULT)
        end
    end

    return result
end

function create_embeddings(text::AbstractString)
    response = @mock OpenAI.create_embeddings(OPENAI_API_KEY, text)
    result = EMPTY_EMBEDDING_RESULT

    @debug_output get_debug_id("embeddings") "OpenAI" response

    response.status != 200 && return result

    if (v = get(response.response, "data", nothing)) isa AbstractDict &&
       (v = get(response, "embedding", nothing)) isa AbstractVector
        result = v
    end

    return result
end
