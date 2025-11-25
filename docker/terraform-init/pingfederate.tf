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

data "pingfederate_data_store" "pingdirectory" {
  data_store_id = "LDAP-4D65BD30F2946A712E86940F0F7442EDCDC16646"
}

# docker compose run --rm terraform-init import pingfederate_idp_adapter.identifierFirstAdapter IDENTIFIERFIRST
resource "pingfederate_idp_adapter" "identifierFirstAdapter" {
  name       = "IDENTIFIERFIRST"
  adapter_id = "IDENTIFIERFIRST"
  configuration = {

  }
  plugin_descriptor_ref = {
    id = "com.pingidentity.adapters.identifierfirst.idp.IdentifierFirstAdapter"
  }
  attribute_mapping = {
    core_attributes = [
      {
        masked    = false
        name      = "domain"
        pseudonym = false
      },
      {
        masked    = false
        name      = "subject"
        pseudonym = true
      }
    ]
    attribute_sources = [
      {
        ldap_attribute_source = {
          base_dn = "ou=People,dc=example,dc=com"
          data_store_ref = {
            id = data.pingfederate_data_store.pingdirectory.data_store_id
          }
          description            = "PINGDIRECTORY"
          id                     = "PINGDIRECTORY"
          member_of_nested_group = false
          search_attributes = [
            "Subject DN",
            "uid",
          ]
          search_filter = "(&(telephoneNumber=$${subject}))"
          search_scope  = "SUBTREE"
          type          = "LDAP"
        }
      }
    ]
    attribute_contract_fulfillment = {
      "domain" = {
        source_type = "ADAPTER"
        value       = "domain"
      }
      "subject" = {
        source_type = "LDAP_DATA_STORE"
        id          = "PINGDIRECTORY"
        value       = "uid"
      }
    }
  }
  attribute_contract = {
    core_attributes = [
      {
        masked    = false
        name      = "domain"
        pseudonym = false
      },
      {
        masked    = false
        name      = "subject"
        pseudonym = true
      },
    ]
  }
}
