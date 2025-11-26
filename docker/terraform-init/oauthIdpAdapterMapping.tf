resource "pingfederate_oauth_idp_adapter_mapping" "identifierfirst" {
  attribute_contract_fulfillment = {
    USER_KEY = {
      source = {
        id   = null
        type = "ADAPTER"
      }
      value = "subject"
    }
    USER_NAME = {
      source = {
        id   = "IDENTIFIERFIRST"
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
        description            = "IDENTIFIERFIRST"
        id                     = "IDENTIFIERFIRST"
        member_of_nested_group = false
        search_attributes      = ["Subject DN", "mail", "uid"]
        search_filter          = "uid=$${subject}"
        search_scope           = "SUBTREE"
        type                   = "LDAP"
      }
    },
  ]
  issuance_criteria = {
    conditional_criteria = [
    ]
    expression_criteria = null
  }
  mapping_id = "IDENTIFIERFIRST"
}
