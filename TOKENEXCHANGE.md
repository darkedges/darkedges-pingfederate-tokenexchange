# Token Exchange

See <https://docs.pingidentity.com/pingfederate/12.3/administrators_reference_guide/pf_config_oauth_token_exchange.html> for details 

## Defining token exchange processor policies

See <https://docs.pingidentity.com/pingfederate/12.3/administrators_reference_guide/pf_defining_token_exchange_processor_policies.html>

### Flow

```text
New Access Token Manager
    Applications -> OAuth -> Access Token Management

New Token processor
    Authentication -> Token Exchange -> Token Processor

New Processor Policy
```

## Enabling token exchange in OAuth clients

See <https://docs.pingidentity.com/pingfederate/12.3/administrators_reference_guide/pf_enabl_token_exchang_oauth_client.html>

### Flow

```text
New OAuth Client
    Applications -> OAuth -> Clients
```

## curl

```bash
curl --location 'https://engine.ping.darkedges.com/as/token.oauth2' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --header 'Authorization: Basic dG9rZW5leGNoYW5nZWNsaWVudDoyRmVkZXJhdGVNMHJl' \
    --data-urlencode 'grant_type=urn:ietf:params:oauth:grant-type:token-exchange' \
    --data-urlencode 'subject_token=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6InJ0c0ZULWItN0x1WTdEVlllU05LY0lKN1ZuYyIsImtpZCI6InJ0c0ZULWItN0x1WTdEVlllU05LY0lKN1ZuYyJ9.eyJhdWQiOiJodHRwczovL2ZyYW0uY29ubmVjdGlkLmRhcmtlZGdlcy5jb20vb3BlbmFtL29hdXRoMiIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzQxNjFiZTNmLWJmMmItNDFkNC1hMDJiLWU2ZjgyYjUyOWQ1My8iLCJpYXQiOjE3NjM0NDA1ODQsIm5iZiI6MTc2MzQ0MDU4NCwiZXhwIjoxNzYzNDQ1OTM2LCJhY3IiOiIxIiwiYWlvIjoiQVpRQWEvOGFBQUFBNnpnVmQyK0Q1SnJFaFNzcHhTcklUOC90Z01YYzhweEJsaXoyMDFiWTRPcHkzdUVlV1RJSGQvcHhQeE9JUlZiSXFJaVIyL0NuQ2MyTE5Rb2VvTjdXb1RqVm5rTzA5OHdnRjdaOEpnLzRGdUJmVXU4WERKRklHR2VNV0pza2p6T2F4dkh0c3E4eVBsUkdGcmdvK2RNWWhlVWlwREF2MVhBb0p3Z002Rm1MbWdOM1ZVTUwrM3B1WVlGbks2RU9zYmdQIiwiYW1yIjpbInB3ZCJdLCJhcHBpZCI6ImVkZDlmMjQxLWQ1NTAtNGRlOC04NDVkLTNmYTI5OTA5MDAxNCIsImFwcGlkYWNyIjoiMCIsImVtYWlsIjoibmlydmluZ3VrQGhvdG1haWwuY29tIiwiZmFtaWx5X25hbWUiOiJJcnZpbmciLCJnaXZlbl9uYW1lIjoiTmljaG9sYXMiLCJpZHAiOiJsaXZlLmNvbSIsImlwYWRkciI6IjI3LjMyLjEzOC45OSIsIm5hbWUiOiJOaWNob2xhcyBJcnZpbmciLCJvaWQiOiI5MzdkMDEwZS05NzlkLTQ3ZjktYTgxZC05MDFmZjM3M2UxNjgiLCJyaCI6IjEuQVdjQVA3NWhRU3VfMUVHZ0stYjRLMUtkVTBIeTJlMVExZWhOaEYwX29wa0pBQlJuQUdsbkFBLiIsInNjcCI6InByb3ZpZGVyLnJlYWQgcHJvdmlkZXIud3JpdGUgdXNlcl9pbXBlcnNvbmF0aW9uIiwic2lkIjoiMDBhOWRjNzktYjgzMS04ZWI5LWI5MjktMDZhZTc3NjVkMDQwIiwic3ViIjoiMEJVVGZPS2ZLYkNpMlJmNFMta3JOY0ZRVUFKMlI0WURJcWY4WHZsNW5LNCIsInRpZCI6IjQxNjFiZTNmLWJmMmItNDFkNC1hMDJiLWU2ZjgyYjUyOWQ1MyIsInVuaXF1ZV9uYW1lIjoibGl2ZS5jb20jbmlydmluZ3VrQGhvdG1haWwuY29tIiwidXRpIjoiSUJYYjR2SEJSazZVOFhmcWwzUTBBQSIsInZlciI6IjEuMCIsInhtc19mdGQiOiJad2VkMzdtNlprYk9Oc3NxUHFHbkFPS0lweS1RYkVabzZlZTdzZlFqalljQllYVnpkSEpoYkdsaFpXRnpkQzFrYzIxeiJ9.b5CGej96UdpaMiZXsCFwIGv3VBwNhxJWkAp68kwhY-EsqVB1ZMKueEypXx4vCkdsU_6cEudB_UQatnkhphCHAjJ99ivZV90N87Pya20t8Ljx3yzNxZvYQ5mWw-7XsfQO2t28pVRdads3wlvjexbooC0ScHkWtmO7GYkFgCWHrcVTltMz-HsrmvWjChlDhG73ZgI60bZi3nVDrUrOPYDmmAyw_dTeNksHMDfXPP7DSaObXlaTbVxPdumhgKt60HcjfEXlvhdPYkkUu2lFB-Z5gXDZi9On63cU1_MdRWo6gGoGFCs-nlUPZWn3wcYAFVCzb2kTTwy2k-lr94-T-E0Ehw' \
    --data-urlencode 'subject_token_type=urn:ietf:params:oauth:token-type:access_token' \
    --data-urlencode 'requested_token_type=urn:ietf:params:oauth:token-type:access_token' \
    --data-urlencode 'scope=openid profile email'
```

returns

```json
{
    "access_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjNzYnNsNl9MUGxyMS1ST0VfdjJYeWNiZWdpMF9SUzI1NiIsInBpLmF0bSI6IjRld3AifQ.eyJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwiYXV0aG9yaXphdGlvbl9kZXRhaWxzIjpbXSwiY2xpZW50X2lkIjoidG9rZW5leGNoYW5nZWNsaWVudCIsImlhdCI6MTc2MzQ0MzUxNiwianRpIjoiekJObVBydkJBa3M2SUJhdkFaM2FwbCIsInN1YiI6IjBCVVRmT0tmS2JDaTJSZjRTLWtyTmNGUVVBSjJSNFlESXFmOFh2bDVuSzQiLCJlbWFpbCI6Im5pcnZpbmd1a0Bob3RtYWlsLmNvbSIsImV4cCI6MTc2MzQ1MDcxNn0.XtcpBxZvyZWUVtk5Daa6D07vO_tuaJ7AgrQ_CYeNlgE0Y7m4xzQyKgtdeBIIrnTECvdxUAgwIQqy42wHKFdF4fHldSIQlZQ6Upv7AOMPVWLFDcFLWixZHNZ0sGzRHqxB7V1l-OM-cU7yJvfCgJcC466juLUB1rMPDvXI8g3X9-CvLH84k-eI0uzK4uyFiqj2sInwQqCoIlefxANelZl6LkVW4eceZDx1tUssZHT6qfd86qSdAI4qnP8p2uZiz9thUlmLdimwpTqIAyUQEFNIlQJrOUGP5ks46jy84SOZy8p7vMCn14FD8Fu2b2wN-b78CRPtpOcY7EckYRTnhhnNTQ",
    "sub": "0BUTfOKfKbCi2Rf4S-krNcFQUAJ2R4YDIqf8Xvl5nK4",
    "issued_token_type": "urn:ietf:params:oauth:token-type:access_token",
    "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjNzYnNsNl9MUGxyMS1ST0VfdjJYeWNiZWdpMF9SUzI1NiJ9.eyJzdWIiOiIwQlVUZk9LZktiQ2kyUmY0Uy1rck5jRlFVQUoyUjRZRElxZjhYdmw1bks0IiwiYXVkIjoidG9rZW5leGNoYW5nZWNsaWVudCIsImp0aSI6IjBZUk93RVNjRmRrcUtFVEhIcmo2V3YiLCJpc3MiOiJodHRwczovL2VuZ2luZS5waW5nLmRhcmtlZGdlcy5jb20iLCJpYXQiOjE3NjM0NDM1MTYsImV4cCI6MTc2MzQ0MzgxNiwiZW1haWwiOiJuaXJ2aW5ndWtAaG90bWFpbC5jb20ifQ.LuRslU69TwkX9XqCBFiadEzwsUXI9ztwWXJjDrmhUyarPPK8D4ZBqfDkG4vYIT3-Ole4QGGxw818FYVtKq6ocGgTrh3WmUaWfkXitpQGYnNhXHZqz91EwbCoth4-IVUZcNmUU9vy1K5BgVrEgnkR5Lyf0bF7AtVSbzA6yOl9Aeb2lLYTfBAPiuu9xYWqpTzJiE225pjQQuYPkrUje2g7m9_yDDF574-wROpvhx2DJxSDJJvnxGxzQJpxTz0adAbkG4r7sYkv9EUWue6hvbBREsi7L9Jmt_dxZ-fCPDBEsYCqqR9coC8V0P2dqmGZrzjKpK6IWuMLFQeOVQDVMHRZKQ",
    "token_type": "Bearer",
    "expires_in": 7199,
    "email": "nirvinguk@hotmail.com"
}
```

### Decoded Access Token

```json
{
  "scope": "openid profile email",
  "authorization_details": [],
  "client_id": "tokenexchangeclient",
  "iat": 1763443516,
  "jti": "zBNmPrvBAks6IBavAZ3apl",
  "sub": "0BUTfOKfKbCi2Rf4S-krNcFQUAJ2R4YDIqf8Xvl5nK4",
  "email": "nirvinguk@hotmail.com",
  "exp": 1763450716
}
```

### Decoded Identity Token

```json
{
  "sub": "0BUTfOKfKbCi2Rf4S-krNcFQUAJ2R4YDIqf8Xvl5nK4",
  "aud": "tokenexchangeclient",
  "jti": "0YROwEScFdkqKETHHrj6Wv",
  "iss": "https://engine.ping.darkedges.com",
  "iat": 1763443516,
  "exp": 1763443816,
  "email": "nirvinguk@hotmail.com"
}
```


## Authentication

![alt text](images/image.png)

## Application

![alt text](images/image-1.png)
![alt text](images/image-2.png)
![alt text](images/image-3.png)
![alt text](images/image-4.png)
![alt text](images/image-5.png)