resource "pingfederate_authentication_api_application" "connectAuthApiApp" {
  name           = "My Sample Application"
  description    = "My Sample application"
  application_id = "t8CAiKyUYjMFmbWWuD92AL3Oc"

  url = "https://contact.ping.darkedges.com"

  client_for_redirectless_mode_ref = {
    id = pingfederate_oauth_client.connectOAuthClient.id
  }
}
