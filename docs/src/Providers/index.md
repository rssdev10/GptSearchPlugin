# Vector storage service providers

The plugin uses a vector storage to store the calculated embedding vectors and doing approximate search.

The plugin can use any storage if it provides it:
- Store vectors up to 2k in size (for OpenAI embeddings);
- Add and remove records by a string ID with a vector and metadata;
- Do an approximate vector search with a distance score.

See the current implementations of the storage interfaces if you want to create a new one.
