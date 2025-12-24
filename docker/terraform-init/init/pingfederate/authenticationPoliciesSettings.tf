resource "pingfederate_authentication_policies_settings" "default" {
  enable_idp_authn_selection = true
  enable_sp_authn_selection  = false
}
