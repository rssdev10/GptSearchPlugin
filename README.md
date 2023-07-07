# GptSearchPlugin
Simple and pure Julia-based implementation of a GPT retrieval plugin logic

## Minimal configuration

Run storage server. Now is available Elasticsearch as a docker-container. [Use this script](providers/Elasticsearch/docker-compose.yml) and run `docker-compose up` in a command line


Setup environment variables:

    export DATASTORE=ELASTICSEARCH
    export OPENAI_API_KEY=sk-ABCDEF...

Be sure that all packages were installed.

    julia --project=. -e "using Pkg; Pkg.instantiate()"


### Local run without authentication

Use `./ws_run.jl` command in a command line. Default address is of the plugin "localhost:3333"

### Production-mode run with authentication

Only BEARER authentication is supported now. Use https://jwt.io/ to generate any token. And specify following variables:

    export BEARER_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.Et9HFtf9R3GEMA0IICOfFMVXY7kkTX1wr4qCyhIf58U
    export APP_ENV=prod

Next, run the application server `./ws_run.jl`

Be sure that [the manifest file](.well-known/ai-plugin.json) contains a correct public domain.

## How to upload data

Now there is the only way to push data - `/upsert` endpoint. Use following format of JSON:

```bash
curl --location 'http://localhost:3333/upsert' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.Et9HFtf9R3GEMA0IICOfFMVXY7kkTX1wr4qCyhIf58U' \
--data '{
  "documents": [
    {
      "id": "c5a8cf58-e68f-d694-c900-da9f8f5d80de",
      "text": "Function-like objects in Julia. Methods are associated with types, so it is possible to make any arbitrary Julia object \"callable\" by adding methods to its type. (Such \"callable\" objects are sometimes called \"functors\".)\n",
      "metadata": {
        "url": "https://docs.julialang.org/en/v1/manual/methods/#Function-like-objects",
        "author": "Community author",
        "title": "Function-like objects",
        "source": "file"
      }
    },
    {
      "id": "fa138fa2-0ba0-4884-11fa-2b005be32081",
      "text": "Function composition and piping.\n Functions in Julia can be combined by composing or piping (chaining) them together.\nFunction composition is when you combine functions together and apply the resulting composition to arguments. You use the function composition operator (∘) to compose the functions, so (f ∘ g)(args...) is the same as f(g(args...)).\n",
      "metadata": {
        "url": "https://docs.julialang.org/en/v1/manual/functions/#Function-composition-and-piping",
        "author": "Community author",
        "title": "Function composition and piping",
        "source": "file"
      }
    }
  ]
}'
```
