# DefaultApi

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**delete_docs**](DefaultApi.md#delete_docs) | **DELETE** /delete | Delete
[**query_post**](DefaultApi.md#query_post) | **POST** /query | Query
[**upsert_post**](DefaultApi.md#upsert_post) | **POST** /upsert | Data upload


# **delete_docs**
> delete_docs(req::HTTP.Request, delete_request::DeleteRequest;) -> DeleteResponse

Delete

Delete one or more documents

### Required Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **req** | **HTTP.Request** | The HTTP Request object | 
**delete_request** | [**DeleteRequest**](DeleteRequest.md)|  | 

### Return type

[**DeleteResponse**](DeleteResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **query_post**
> query_post(req::HTTP.Request, query_request::QueryRequest;) -> QueryResponse

Query

Accepts search query objects array each with query and optional filter. Break down complex questions into sub-questions. Refine results by criteria, e.g. time / source, don't do this often. Split queries if ResponseTooLargeError occurs.

### Required Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **req** | **HTTP.Request** | The HTTP Request object | 
**query_request** | [**QueryRequest**](QueryRequest.md)|  | 

### Return type

[**QueryResponse**](QueryResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **upsert_post**
> upsert_post(req::HTTP.Request, upsert_request::UpsertRequest;) -> UpsertResponse

Data upload

Upload JSON document description

### Required Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **req** | **HTTP.Request** | The HTTP Request object | 
**upsert_request** | [**UpsertRequest**](UpsertRequest.md)|  | 

### Return type

[**UpsertResponse**](UpsertResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

