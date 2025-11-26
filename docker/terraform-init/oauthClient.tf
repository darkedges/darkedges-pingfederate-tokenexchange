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
  allow_authentication_api_init = true
}
