resource "pingfederate_oauth_access_token_mapping" "default" {
  access_token_manager_ref = {
    id = "AccessTokenManagement"
  }
  attribute_contract_fulfillment = {
    email = {
      source = {
        id   = "PINGDIRECTORY"
        type = "LDAP_DATA_STORE"
      }
      value = "mail"
    }
    sub = {
      source = {
        id   = "PINGDIRECTORY"
        type = "LDAP_DATA_STORE"
      }
      value = "uid"
    }
  }
  attribute_sources = [
    {
      custom_attribute_source = null
      jdbc_attribute_source   = null
      ldap_attribute_source = {
        attribute_contract_fulfillment = null
        base_dn                        = "ou=People,dc=example,dc=com"
        binary_attribute_settings      = null
        data_store_ref = {
          id = "LDAP-4D65BD30F2946A712E86940F0F7442EDCDC16646"
        }
        description            = "PINGDIRECTORY"
        id                     = "PINGDIRECTORY"
        member_of_nested_group = false
        search_attributes      = ["Subject DN", "mail", "uid"]
        search_filter          = "uid=$${USER_KEY}"
        search_scope           = "SUBTREE"
        type                   = "LDAP"
      }
    },
  ]
  context = {
    context_ref = null
    type        = "DEFAULT"
  }
  issuance_criteria = {
    conditional_criteria = [
    ]
    expression_criteria = null
  }
}
