# {{classname}}

All URIs are relative to *http://localhost/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**CheckHealth**](DefaultApi.md#CheckHealth) | **Get** /healthz | Node Health
[**HelloUser**](DefaultApi.md#HelloUser) | **Get** /hello/{user} | Returns a greeting to the user!

# **CheckHealth**
> string CheckHealth(ctx, )
Node Health

### Required Parameters
This endpoint does not need any parameter.

### Return type

**string**

### Authorization

[basicAuth](../README.md#basicAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/plain, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **HelloUser**
> string HelloUser(ctx, user)
Returns a greeting to the user!

### Required Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ctx** | **context.Context** | context for authentication, logging, cancellation, deadlines, tracing, etc.
  **user** | **string**| The name of the user to greet. | 

### Return type

**string**

### Authorization

[basicAuth](../README.md#basicAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/plain

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

