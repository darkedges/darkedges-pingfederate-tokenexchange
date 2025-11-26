resource "pingfederate_oauth_server_settings" "default" {
  authorization_code_timeout = 60
  refresh_token_length       = 42
  refresh_rolling_interval   = 0
  authorization_code_entropy = 30
  persistent_grant_reuse_grant_types = [
    "IMPLICIT",
  ]
  scopes = [
    {
      description = "email"
      dynamic     = false
      name        = "email"
    },
    {
      description = "profile"
      dynamic     = false
      name        = "profile"
    },
  ]
}
