resource "pingfederate_authentication_policies" "identityFirstPolicy" {
  authn_selection_trees = [
    {
      authentication_api_application_ref = null
      description                        = null
      enabled                            = true
      handle_failures_locally            = false
      id                                 = "IDENTIFIERFIRSTPOLICY"
      name                               = "IDENTIFIERFIRSTPOLICY"
      root_node = {
        action = {
          apc_mapping_policy_action    = null
          authn_selector_policy_action = null
          authn_source_policy_action = {
            attribute_rules = null
            authentication_source = {
              source_ref = {
                id = "IDENTIFIERFIRST"
              }
              type = "IDP_ADAPTER"
            }
            context               = null
            input_user_id_mapping = null
            user_id_authenticated = null
          }
          continue_policy_action               = null
          done_policy_action                   = null
          fragment_policy_action               = null
          local_identity_mapping_policy_action = null
          restart_policy_action                = null
        }
        children = [
          {
            action = {
              apc_mapping_policy_action            = null
              authn_selector_policy_action         = null
              authn_source_policy_action           = null
              continue_policy_action               = null
              done_policy_action                   = null
              fragment_policy_action               = null
              local_identity_mapping_policy_action = null
              restart_policy_action = {
                context = "Fail"
              }
            }
            children = [
            ]
          },
          {
            action = {
              apc_mapping_policy_action    = null
              authn_selector_policy_action = null
              authn_source_policy_action = {
                attribute_rules = null
                authentication_source = {
                  source_ref = {
                    id = "PINGONEMFA"
                  }
                  type = "IDP_ADAPTER"
                }
                context               = "Success"
                input_user_id_mapping = null
                user_id_authenticated = null
              }
              continue_policy_action               = null
              done_policy_action                   = null
              fragment_policy_action               = null
              local_identity_mapping_policy_action = null
              restart_policy_action                = null
            }
            children = [
              {
                action = {
                  apc_mapping_policy_action            = null
                  authn_selector_policy_action         = null
                  authn_source_policy_action           = null
                  continue_policy_action               = null
                  done_policy_action                   = null
                  fragment_policy_action               = null
                  local_identity_mapping_policy_action = null
                  restart_policy_action = {
                    context = "Fail"
                  }
                }
                children = [
                ]
              },
              {
                action = {
                  apc_mapping_policy_action    = null
                  authn_selector_policy_action = null
                  authn_source_policy_action   = null
                  continue_policy_action       = null
                  done_policy_action = {
                    context = "Success"
                  }
                  fragment_policy_action               = null
                  local_identity_mapping_policy_action = null
                  restart_policy_action                = null
                }
                children = [
                ]
              },
            ]
          },
        ]
      }
    },
  ]
  default_authentication_sources = [
  ]
  fail_if_no_selection    = false
  tracked_http_parameters = []
}
