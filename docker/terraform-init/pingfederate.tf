resource "pingfederate_administrative_account" "administrativeAccount" {
  username    = "nirving"
  description = "description"
  password    = "Passw0rd"
  roles = [
    "ADMINISTRATOR",
    "CRYPTO_ADMINISTRATOR",
    "DATA_COLLECTION_ADMINISTRATOR",
    "EXPRESSION_ADMINISTRATOR",
    "USER_ADMINISTRATOR"
  ]
  active = true
}

resource "pingfederate_authentication_api_application" "connectAuthApiApp" {
  name           = "My Sample Application"
  description    = "My Sample application"
  application_id = "t8CAiKyUYjMFmbWWuD92AL3Oc"

  url = "https://contact.ping.darkedges.com"

  client_for_redirectless_mode_ref = {
    id = pingfederate_oauth_client.connectOAuthClient.id
  }
}
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
