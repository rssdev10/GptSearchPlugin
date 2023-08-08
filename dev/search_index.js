var documenterSearchIndex = {"docs":
[{"location":"Providers/#Vector-storage-service-providers","page":"Getting Started","title":"Vector storage service providers","text":"","category":"section"},{"location":"Providers/","page":"Getting Started","title":"Getting Started","text":"The plugin uses a vector storage to store the calculated embedding vectors and doing approximate search.","category":"page"},{"location":"Providers/","page":"Getting Started","title":"Getting Started","text":"The plugin can use any storage if it provides it:","category":"page"},{"location":"Providers/","page":"Getting Started","title":"Getting Started","text":"Store vectors up to 2k in size (for OpenAI embeddings);\nAdd and remove records by a string ID with a vector and metadata;\nDo an approximate vector search with a distance score.","category":"page"},{"location":"Providers/","page":"Getting Started","title":"Getting Started","text":"See the current implementations of the storage interfaces if you want to create a new one.","category":"page"},{"location":"API/#Generated-API-documentation","page":"API","title":"Generated API documentation","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"The code is generated by the OpenAPI generator with the Julia plugin.","category":"page"},{"location":"API/","page":"API","title":"API","text":"Modules = [GptSearchPlugin.AppServer.GptPluginServer]","category":"page"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer","text":"Encapsulates generated server code for GptPluginServer\n\nThe following server methods must be implemented:\n\nqueryquerypost\ninvocation: POST /query\nsignature: queryquerypost(req::HTTP.Request, query_request::QueryRequest;) -> QueryResponse\nupsert_post\ninvocation: POST /upsert\nsignature: upsertpost(req::HTTP.Request; upsertrequest=nothing,) -> UpsertResponse\n\n\n\n\n\n","category":"module"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.Document","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.Document","text":"Document\n\nDocument(;\n    id=nothing,\n    text=nothing,\n    metadata=nothing,\n)\n\n- id::String\n- text::String\n- metadata::DocumentMetadata\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.DocumentChunk","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.DocumentChunk","text":"DocumentChunk\n\nDocumentChunk(;\n    id=nothing,\n    text=nothing,\n    metadata=nothing,\n    embedding=nothing,\n    score=nothing,\n)\n\n- id::String\n- text::String\n- metadata::DocumentChunkMetadata\n- embedding::Vector{Float64}\n- score::Float64\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.DocumentChunkMetadata","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.DocumentChunkMetadata","text":"DocumentChunkMetadata\n\nDocumentChunkMetadata(;\n    source=nothing,\n    source_id=nothing,\n    url=nothing,\n    created_at=nothing,\n    author=nothing,\n    document_id=nothing,\n)\n\n- source::Source\n- source_id::String\n- url::String\n- created_at::String\n- author::String\n- document_id::String\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.DocumentChunkWithScore","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.DocumentChunkWithScore","text":"DocumentChunkWithScore\n\nDocumentChunkWithScore(;\n    id=nothing,\n    text=nothing,\n    metadata=nothing,\n    embedding=nothing,\n    score=nothing,\n)\n\n- id::String\n- text::String\n- metadata::DocumentChunkMetadata\n- embedding::Vector{Float64}\n- score::Float64\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.DocumentMetadata","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.DocumentMetadata","text":"DocumentMetadata\n\nDocumentMetadata(;\n    source=nothing,\n    source_id=nothing,\n    url=nothing,\n    created_at=nothing,\n    author=nothing,\n)\n\n- source::Source\n- source_id::String\n- url::String\n- created_at::String\n- author::String\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.DocumentMetadataFilter","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.DocumentMetadataFilter","text":"DocumentMetadataFilter\n\nDocumentMetadataFilter(;\n    document_id=nothing,\n    source=nothing,\n    source_id=nothing,\n    author=nothing,\n    start_date=nothing,\n    end_date=nothing,\n)\n\n- document_id::String\n- source::Source\n- source_id::String\n- author::String\n- start_date::String\n- end_date::String\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.HTTPValidationError","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.HTTPValidationError","text":"HTTPValidationError\n\nHTTPValidationError(;\n    detail=nothing,\n)\n\n- detail::Vector{ValidationError}\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.LocationInner","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.LocationInner","text":"Location_inner\n\nLocationInner(; value=nothing)\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.Query","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.Query","text":"Query\n\nQuery(;\n    query=nothing,\n    filter=nothing,\n    top_k=3,\n)\n\n- query::String\n- filter::DocumentMetadataFilter\n- top_k::Int64\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.QueryRequest","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.QueryRequest","text":"QueryRequest\n\nQueryRequest(;\n    queries=nothing,\n)\n\n- queries::Vector{Query}\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.QueryResponse","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.QueryResponse","text":"QueryResponse\n\nQueryResponse(;\n    results=nothing,\n)\n\n- results::Vector{QueryResult}\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.QueryResult","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.QueryResult","text":"QueryResult\n\nQueryResult(;\n    query=nothing,\n    results=nothing,\n)\n\n- query::String\n- results::Vector{DocumentChunkWithScore}\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.QueryWithEmbedding","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.QueryWithEmbedding","text":"QueryWithEmbedding\n\nQueryWithEmbedding(;\n    query=nothing,\n    filter=nothing,\n    top_k=3,\n    embedding=nothing,\n)\n\n- query::String\n- filter::DocumentMetadataFilter\n- top_k::Int64\n- embedding::Vector{Float64}\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.UpsertRequest","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.UpsertRequest","text":"UpsertRequest\n\nUpsertRequest(;\n    documents=nothing,\n)\n\n- documents::Vector{Document}\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.UpsertResponse","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.UpsertResponse","text":"UpsertResponse\n\nUpsertResponse(;\n    ids=nothing,\n)\n\n- ids::Vector{String}\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.ValidationError","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.ValidationError","text":"ValidationError\n\nValidationError(;\n    loc=nothing,\n    msg=nothing,\n    type=nothing,\n)\n\n- loc::Vector{LocationInner}\n- msg::String\n- type::String\n\n\n\n\n\n","category":"type"},{"location":"API/#GptSearchPlugin.AppServer.GptPluginServer.register-Tuple{HTTP.Handlers.Router, Any}","page":"API","title":"GptSearchPlugin.AppServer.GptPluginServer.register","text":"Register handlers for all APIs in this module in the supplied Router instance.\n\nParamerets:\n\nrouter: Router to register handlers in\nimpl: module that implements the server methods\n\nOptional parameters:\n\npath_prefix: prefix to be applied to all paths\noptional_middlewares: Register one or more optional middlewares to be applied to all requests.\n\nOptional middlewares can be one or more of:     - init: called before the request is processed     - pre_validation: called after the request is parsed but before validation     - pre_invoke: called after validation but before the handler is invoked     - post_invoke: called after the handler is invoked but before the response is sent\n\nThe order in which middlewares are invoked are: init |> read |> pre_validation |> validate |> pre_invoke |> invoke |> post_invoke\n\n\n\n\n\n","category":"method"},{"location":"Providers/Elasticsearch/#Elasticsearch-as-a-vector-storage","page":"Elasticsearch","title":"Elasticsearch as a vector storage","text":"","category":"section"},{"location":"Providers/Elasticsearch/","page":"Elasticsearch","title":"Elasticsearch","text":"Elasticsearch can be installed in a number of ways. But the easiest way to have it locally without authentication is to use Docker. Use our compose-script and run the following command in a terminal:","category":"page"},{"location":"Providers/Elasticsearch/","page":"Elasticsearch","title":"Elasticsearch","text":"docker-compose up","category":"page"},{"location":"Providers/Elasticsearch/","page":"Elasticsearch","title":"Elasticsearch","text":"If you want to configure a cluster see full instructions","category":"page"},{"location":"Providers/Elasticsearch/","page":"Elasticsearch","title":"Elasticsearch","text":"To enable ElasticSearch use:","category":"page"},{"location":"Providers/Elasticsearch/","page":"Elasticsearch","title":"Elasticsearch","text":"export DATASTORE=ELASTICSEARCH","category":"page"},{"location":"Providers/Opensearch/#OpenSearch-as-a-vector-storage","page":"OpenSearch","title":"OpenSearch as a vector storage","text":"","category":"section"},{"location":"Providers/Opensearch/","page":"OpenSearch","title":"OpenSearch","text":"OpenSearch is a search application licensed under Apache 2.0 and available as a cloud solution on AWS.  OpenSearch can be installed in a number of ways. But the easiest way to have it locally without authentication is to use Docker.","category":"page"},{"location":"Providers/Opensearch/","page":"OpenSearch","title":"OpenSearch","text":"Use our compose-script and run the following command in a terminal:","category":"page"},{"location":"Providers/Opensearch/","page":"OpenSearch","title":"OpenSearch","text":"docker-compose up","category":"page"},{"location":"Providers/Opensearch/","page":"OpenSearch","title":"OpenSearch","text":"If you want to configure a cluster see full instructions","category":"page"},{"location":"Providers/Opensearch/","page":"OpenSearch","title":"OpenSearch","text":"To enable OpenSearch use:","category":"page"},{"location":"Providers/Opensearch/","page":"OpenSearch","title":"OpenSearch","text":"export DATASTORE=OPENSEARCH","category":"page"},{"location":"#GptSearchPlugin.jl","page":"Home","title":"GptSearchPlugin.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for GptSearchPlugin.jl","category":"page"},{"location":"Internals/#Internal-functions","page":"Internals","title":"Internal functions","text":"","category":"section"},{"location":"Internals/","page":"Internals","title":"Internals","text":"Modules = [GptSearchPlugin, GptSearchPlugin.AppServer, GptSearchPlugin.AppServer.DataStore]","category":"page"},{"location":"Internals/#GptSearchPlugin.AppServer.create_document_chunks","page":"Internals","title":"GptSearchPlugin.AppServer.create_document_chunks","text":"Create a list of document chunks from a document object and return the document id.\n\nArgs:     doc: The document object to create chunks from. It should have a text attribute and optionally an id and a metadata attribute.     chunktokensize: The target size of each chunk in tokens, or None to use the default CHUNK_SIZE.\n\nReturns:     A tuple of (docchunks, docid), where docchunks is a list of document chunks, each of which is a DocumentChunk object with an id, a documentid, a text, and a metadata attribute,     and doc_id is the id of the document object, generated if not provided. The id of each chunk is generated from the document id and a sequential number, and the metadata is copied from the document object.\n\n\n\n\n\n","category":"function"},{"location":"Internals/#GptSearchPlugin.AppServer.get_document_chunks","page":"Internals","title":"GptSearchPlugin.AppServer.get_document_chunks","text":"Convert a list of documents into a dictionary from document id to list of document chunks.\n\nArgs:     documents: The list of documents to convert.     chunktokensize: The target size of each chunk in tokens, or None to use the default CHUNK_SIZE.\n\nReturns:     A dictionary mapping each document id to a list of document chunks, each of which is a DocumentChunk object     with text, metadata, and embedding attributes.\n\n\n\n\n\n","category":"function"},{"location":"Internals/#GptSearchPlugin.AppServer.get_text_chunks","page":"Internals","title":"GptSearchPlugin.AppServer.get_text_chunks","text":"Split a text into chunks of ~CHUNK_SIZE tokens, based on punctuation and newline boundaries.\n\nArgs:     text: The text to split into chunks.     chunktokensize: The target size of each chunk in tokens, or None to use the default CHUNK_SIZE.\n\nReturns:     A list of text chunks, each of which is a string of ~CHUNK_SIZE tokens.\n\n\n\n\n\n","category":"function"},{"location":"Internals/#GptSearchPlugin.AppServer.query_query_post-Tuple{HTTP.Messages.Request, GptSearchPlugin.AppServer.GptPluginServer.QueryRequest}","page":"Internals","title":"GptSearchPlugin.AppServer.query_query_post","text":"invocation: POST /query\n\n\n\n\n\n","category":"method"},{"location":"Internals/#GptSearchPlugin.AppServer.upsert_post-Tuple{HTTP.Messages.Request}","page":"Internals","title":"GptSearchPlugin.AppServer.upsert_post","text":"invocation: POST /upsert\n\n\n\n\n\n","category":"method"},{"location":"Internals/#GptSearchPlugin.AppServer.validate_bearer_token-Tuple{HTTP.Messages.Request, String, AbstractSet}","page":"Internals","title":"GptSearchPlugin.AppServer.validate_bearer_token","text":"User authentication\n\nCheck Bearer token\n\n\n\n\n\n","category":"method"},{"location":"Internals/#GptSearchPlugin.AppServer.DataStore.delete-Tuple{GptSearchPlugin.AppServer.DataStore.AbstractStorage}","page":"Internals","title":"GptSearchPlugin.AppServer.DataStore.delete","text":"Removes vectors by ids, filter. Multiple parameters can be used at once.\n\nReturns whether the operation was successful.\n\n\n\n\n\n","category":"method"},{"location":"Internals/#GptSearchPlugin.AppServer.DataStore.delete_all-Tuple{GptSearchPlugin.AppServer.DataStore.AbstractStorage}","page":"Internals","title":"GptSearchPlugin.AppServer.DataStore.delete_all","text":"Removes everything in the datastore\n\nReturns whether the operation was successful.\n\n\n\n\n\n","category":"method"},{"location":"Internals/#GptSearchPlugin.AppServer.DataStore.query-Tuple{AbstractVector{GptSearchPlugin.AppServer.GptPluginServer.Query}}","page":"Internals","title":"GptSearchPlugin.AppServer.DataStore.query","text":"Takes in a list of queries and filters and returns a list of query results with matching document chunks and scores.\n\n\n\n\n\n","category":"method"},{"location":"Internals/#GptSearchPlugin.AppServer.DataStore.query-Tuple{GptSearchPlugin.AppServer.DataStore.AbstractStorage, AbstractVector{GptSearchPlugin.AppServer.GptPluginServer.QueryWithEmbedding}}","page":"Internals","title":"GptSearchPlugin.AppServer.DataStore.query","text":"Takes in a list of queries with embeddings and filters and  returns a list of query results with matching document chunks and scores.\n\n\n\n\n\n","category":"method"},{"location":"Internals/#GptSearchPlugin.AppServer.DataStore.upsert-Tuple{AbstractVector{GptSearchPlugin.AppServer.GptPluginServer.Document}}","page":"Internals","title":"GptSearchPlugin.AppServer.DataStore.upsert","text":"Takes in a list of documents and inserts them into the database. First deletes all the existing vectors with the document id (if necessary, depends on the vector db),  then inserts the new ones.\n\nReturn a list of document ids.\n\n\n\n\n\n","category":"method"},{"location":"Internals/#GptSearchPlugin.AppServer.DataStore.upsert-Tuple{GptSearchPlugin.AppServer.DataStore.AbstractStorage, Dict{String, <:AbstractVector{GptSearchPlugin.AppServer.GptPluginServer.DocumentChunk}}}","page":"Internals","title":"GptSearchPlugin.AppServer.DataStore.upsert","text":"Takes in a list of list of document chunks and inserts them into the database.\n\nReturn a list of document ids.\n\n\n\n\n\n","category":"method"}]
}