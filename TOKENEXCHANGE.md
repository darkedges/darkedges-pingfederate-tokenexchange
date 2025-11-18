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
curl -X POST \
  "https://engine.ping.darkedges.com/as/token.oauth2" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Authorization: Basic dG9rZW5leGNoYW5nZWNsaWVudDoyRmVkZXJhdGVNMHJl" \
  -d "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
  -d "subject_token=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6InJ0c0ZULWItN0x1WTdEVlllU05LY0lKN1ZuYyIsImtpZCI6InJ0c0ZULWItN0x1WTdEVlllU05LY0lKN1ZuYyJ9.eyJhdWQiOiJodHRwczovL2ZyYW0uY29ubmVjdGlkLmRhcmtlZGdlcy5jb20vb3BlbmFtL29hdXRoMiIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzQxNjFiZTNmLWJmMmItNDFkNC1hMDJiLWU2ZjgyYjUyOWQ1My8iLCJpYXQiOjE3NjM0MzU0NzgsIm5iZiI6MTc2MzQzNTQ3OCwiZXhwIjoxNzYzNDQwODQ3LCJhY3IiOiIxIiwiYWlvIjoiQVpRQWEvOGFBQUFBUERvdVNPWVcwTGsxYUhXWERuVXZ4Q2t2Y1B3Znk0djlZRGlQNUlxRnFIdTd6R0dWeEZ3TXVRZnpRVUZXeTBJbHJ0Uk5YOGxILzZmYmJtL0s1RzVuWmdRVlpFYjVnL1pqZTJpUU5FMHREYWZEOE9henc3UElMNTYvdWw4a2Z5NDhSKzRKWWZSZEpzejQzZWh6RFhxNEdUK3huSXNKVktvV1F2SGhub1QxdXRWY3NVSjVZeU1GVWYvUDVacUw3REoyIiwiYW1yIjpbInB3ZCJdLCJhcHBpZCI6ImVkZDlmMjQxLWQ1NTAtNGRlOC04NDVkLTNmYTI5OTA5MDAxNCIsImFwcGlkYWNyIjoiMCIsImVtYWlsIjoibmlydmluZ3VrQGhvdG1haWwuY29tIiwiZmFtaWx5X25hbWUiOiJJcnZpbmciLCJnaXZlbl9uYW1lIjoiTmljaG9sYXMiLCJpZHAiOiJsaXZlLmNvbSIsImlwYWRkciI6IjI3LjMyLjEzOC45OSIsIm5hbWUiOiJOaWNob2xhcyBJcnZpbmciLCJvaWQiOiI5MzdkMDEwZS05NzlkLTQ3ZjktYTgxZC05MDFmZjM3M2UxNjgiLCJyaCI6IjEuQVdjQVA3NWhRU3VfMUVHZ0stYjRLMUtkVTBIeTJlMVExZWhOaEYwX29wa0pBQlJuQUdsbkFBLiIsInNjcCI6InByb3ZpZGVyLnJlYWQgcHJvdmlkZXIud3JpdGUgdXNlcl9pbXBlcnNvbmF0aW9uIiwic2lkIjoiMDBhOWRjNzktYjgzMS04ZWI5LWI5MjktMDZhZTc3NjVkMDQwIiwic3ViIjoiMEJVVGZPS2ZLYkNpMlJmNFMta3JOY0ZRVUFKMlI0WURJcWY4WHZsNW5LNCIsInRpZCI6IjQxNjFiZTNmLWJmMmItNDFkNC1hMDJiLWU2ZjgyYjUyOWQ1MyIsInVuaXF1ZV9uYW1lIjoibGl2ZS5jb20jbmlydmluZ3VrQGhvdG1haWwuY29tIiwidXRpIjoiZHIxN0FmZ0FxRXVpbXdmeGIxVTZBQSIsInZlciI6IjEuMCIsInhtc19mdGQiOiJJZC1SdTBJWXlhaFM1YTlOS19ERk4wcHYzVFhZR3JVLWpydllZQkpaUDVzQllYVnpkSEpoYkdsaFpXRnpkQzFrYzIxeiJ9.iY09X-SBfFyUNEInFFAXHTLTYJOnjvq_o8iaChCJ2-nbd1Obhc8W2lgQf6xUOIfqVpfc8mVkttN-OtTrQpEd0cMuGDzxbB2uRmGi7bf6y4_nTM8YF6NO8GpPaNiMnBKNhlI9qOuNg74ePdzYmTwF2UFcuM4txAFGelgTiC1gBKITWBh9zHbJRVtoBVU76Q3nKU48DoHoEgOUq5cX3qrgqO2kUQOluac58D7cxk4DcNct1TPYZHkS72avgGP5qqsiZyoej_3Un5LUwQ7IXUVgFqnmRWnWqvba3cHsLp6xYMTPESeeouM0FfL8pG48hMT5swv-YygxURg61mReuBntPA" \
  -d "subject_token_type=urn:ietf:params:oauth:token-type:access_token" \
  -d "requested_token_type=urn:ietf:params:oauth:token-type:access_token" \
  -d "audience=https://admin.ping.darkedges.com" \
  -d "scope=openid"
```
