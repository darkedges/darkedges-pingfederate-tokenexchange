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
      },
      {
        masked    = false
        name      = "telephoneNumber"
        pseudonym = false
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
          search_filter = "(&(telephoneNumber=$${telephoneNumber}))"
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
      "telephoneNumber" = {
        source_type = "LDAP_DATA_STORE"
        id          = "PINGDIRECTORY"
        value       = "telephoneNumber"
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
    extended_attributes = [
      {
        masked    = false
        name      = "telephoneNumber"
        pseudonym = false
      },
    ]
  }
}

resource "pingfederate_idp_adapter" "pingOneMfaAdapter" {
  adapter_id = "PINGONEMFA"
  attribute_contract = {
    core_attributes = [
      {
        masked    = false
        name      = "access_token"
        pseudonym = false
      },
      {
        masked    = false
        name      = "authentication.code.flow.userid"
        pseudonym = false
      },
      {
        masked    = false
        name      = "id_token"
        pseudonym = false
      },
      {
        masked    = false
        name      = "pingid.sdk.status"
        pseudonym = false
      },
      {
        masked    = false
        name      = "pingid.sdk.status.reason"
        pseudonym = false
      },
      {
        masked    = false
        name      = "pingone.mfa.status"
        pseudonym = false
      },
      {
        masked    = false
        name      = "pingone.mfa.status.reason"
        pseudonym = false
      },
      {
        masked    = false
        name      = "policy.action"
        pseudonym = false
      },
      {
        masked    = false
        name      = "username"
        pseudonym = true
      },
      {
        masked    = false
        name      = "usernameless.flow.platform"
        pseudonym = false
      },
      {
        masked    = false
        name      = "usernameless.flow.userid"
        pseudonym = false
      },
    ]
    extended_attributes = [
    ]
    mask_ognl_values          = false
    unique_user_key_attribute = null
  }
  attribute_mapping = {
    attribute_contract_fulfillment = {
      access_token = {
        source = {
          id   = null
          type = "ADAPTER"
        }
        value = "access_token"
      }
      "authentication.code.flow.userid" = {
        source = {
          id   = null
          type = "ADAPTER"
        }
        value = "authentication.code.flow.userid"
      }
      id_token = {
        source = {
          id   = null
          type = "ADAPTER"
        }
        value = "id_token"
      }
      "pingid.sdk.status" = {
        source = {
          id   = null
          type = "ADAPTER"
        }
        value = "pingid.sdk.status"
      }
      "pingid.sdk.status.reason" = {
        source = {
          id   = null
          type = "ADAPTER"
        }
        value = "pingid.sdk.status.reason"
      }
      "pingone.mfa.status" = {
        source = {
          id   = null
          type = "ADAPTER"
        }
        value = "pingone.mfa.status"
      }
      "pingone.mfa.status.reason" = {
        source = {
          id   = null
          type = "ADAPTER"
        }
        value = "pingone.mfa.status.reason"
      }
      "policy.action" = {
        source = {
          id   = null
          type = "ADAPTER"
        }
        value = "policy.action"
      }
      username = {
        source = {
          id   = null
          type = "ADAPTER"
        }
        value = "username"
      }
      "usernameless.flow.platform" = {
        source = {
          id   = null
          type = "ADAPTER"
        }
        value = "usernameless.flow.platform"
      }
      "usernameless.flow.userid" = {
        source = {
          id   = null
          type = "ADAPTER"
        }
        value = "usernameless.flow.userid"
      }
    }
    attribute_sources = [
    ]
    issuance_criteria = {
      conditional_criteria = [
      ]
      expression_criteria = null
    }
  }
  authn_ctx_class_ref = null
  configuration = {
    fields = [
      {
        name  = "API Request Timeout"
        value = jsonencode(12000)
      },
      {
        name  = "Allow Users to Add Additional Authentication Methods"
        value = jsonencode(false)
      },
      {
        name  = "Allow Users to Skip MFA Setup"
        value = jsonencode(false)
      },
      {
        name  = "Allow only predefine values for phone or email devices"
        value = jsonencode(false)
      },
      {
        name  = "Allow users to perform multiple device management operations consecutively"
        value = jsonencode(false)
      },
      {
        name  = "Application ID For Authentication Code Flow"
        value = ""
      },
      {
        name  = "Application"
        value = "b23307a6-f5ee-4c05-93f5-8aeb83beaf12"
      },
      {
        name  = "Bypass MFA for device management attribute"
        value = ""
      },
      {
        name  = "Change Device"
        value = "Allow"
      },
      {
        name  = "Custom Proxy Connection Type"
        value = "HTTP"
      },
      {
        name  = "Custom Proxy Host"
        value = ""
      },
      {
        name  = "Custom Proxy Port"
        value = ""
      },
      {
        name  = "DEFAULT AUTHENTICATION METHOD FOR PROVISIONED USERS"
        value = "SMS"
      },
      {
        name  = "Email Attribute"
        value = "email"
      },
      {
        name  = "Enable Audit Log"
        value = jsonencode(false)
      },
      {
        name  = "Enable Cookie Based Tracking"
        value = jsonencode(false)
      },
      {
        name  = "HTML Template Prefix"
        value = "pingone-mfa"
      },
      {
        name  = "MFA policy for registration"
        value = ""
      },
      {
        name  = "Messages Files"
        value = "pingone-mfa-messages"
      },
      {
        name  = "Notification Template Variant Override"
        value = ""
      },
      {
        name  = "Overwrite Authentication Methods"
        value = jsonencode(false)
      },
      {
        name  = "PingOne Authentication API"
        value = "https://auth.pingone.com"
      },
      {
        name  = "PingOne Authentication Policy"
        value = ""
      },
      {
        name  = "PingOne Environment"
        value = "mImpgs4t0rrk7n7mfAMOcP|314177e2-5da7-433b-a5b5-9bdcc20b45a3"
      },
      {
        name  = "PingOne Management API"
        value = "https://api.pingone.com"
      },
      {
        name  = "PingOne Population"
        value = "3ff5b0e7-3eda-4e70-9a92-412453ab5243"
      },
      {
        name  = "Prompt Users to Set Up MFA"
        value = jsonencode(false)
      },
      {
        name  = "Provision Authentication Methods"
        value = jsonencode(false)
      },
      {
        name  = "Provision Users and Authentication Methods"
        value = jsonencode(false)
      },
      {
        name  = "Proxy Settings"
        value = "System Defaults"
      },
      {
        name  = "SMS Attribute"
        value = "sms"
      },
      {
        name  = "Service Unavailable Failure Mode"
        value = "Bypass authentication"
      },
      {
        name  = "Show Error Screens"
        value = jsonencode(true)
      },
      {
        name  = "Show Success Screens"
        value = jsonencode(true)
      },
      {
        name  = "Show Timeout Screens"
        value = jsonencode(true)
      },
      {
        name  = "Test Username"
        value = "nirving"
      },
      {
        name  = "Update Authentication Methods"
        value = jsonencode(false)
      },
      {
        name  = "Use Password Config Attribute"
        value = ""
      },
      {
        name  = "User Not Found Failure Mode"
        value = "Block user"
      },
      {
        name  = "Username Attribute"
        value = ""
      },
      {
        name  = "Voice Attribute"
        value = "voice"
      },
      {
        name  = "WhatsApp Attribute"
        value = "whatsapp"
      },
    ]
    sensitive_fields = [
    ]
    tables = [
    ]
  }
  name       = "PINGONEMFA"
  parent_ref = null
  plugin_descriptor_ref = {
    id = "com.pingidentity.adapters.pingone.mfa.PingOneMfaIdpAdapter"
  }
}
