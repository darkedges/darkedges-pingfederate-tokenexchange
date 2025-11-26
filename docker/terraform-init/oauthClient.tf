resource "pingfederate_oauth_client" "connectOAuthClient" {
  name        = "Contact Client"
  description = "Contact Client for testing purposes"
  client_id   = "contact-oauth-client"
  redirect_uris = [
    "https://contact.ping.darkedges.com/callback"
  ]
  grant_types = [
    "AUTHORIZATION_CODE",
  ]
  allow_authentication_api_init        = true
  enable_cookieless_authentication_api = true
  client_auth = {
    type             = "SECRET"
    encrypted_secret = "OBF:JWE:eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4Q0JDLUhTMjU2Iiwia2lkIjoiUWVzOVR5eTV5WiIsInZlcnNpb24iOiIxMi4zLjEuMCJ9..AAMWtW0oOCyXdJgVJW61kg.ifjfHIAoFWU5Ncp4UCjXi8_OlCftoteiM8NDk-M2ELi_IJ9nlU-rvKOmADYj_NAV20bTZUfdO7V9FZvoxJCeX9lpP3rsRG-jOBvS5ULvkvs.08WOY-mWiTnlJeCF70r1sQ"
  }
  restrict_scopes = true
  restricted_scopes = [
    "openid"
  ]
}
