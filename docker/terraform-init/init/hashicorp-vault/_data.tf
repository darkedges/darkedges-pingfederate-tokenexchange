data "local_file" "config_files" {
  for_each = toset([
    for f in fileset(path.module, "{applications,identities,identity_groups,pki-auth-roles,pkiroles}/*.yaml") : f
    if f != "applications/example.yaml" &&
    f != "identities/example.yaml" &&
    f != "identity_groups/example.yaml" &&
    f != "pki-auth-roles/example.yaml" &&
    f != "pkiroles/example.yaml"
  ])
  filename = "${path.module}/${each.value}"
}

locals {
  all_configs = {
    for path, file in data.local_file.config_files :
    path => try(yamldecode(file.content), null)
  }
  valid_configs = {
    for path, config in local.all_configs :
    path => config if config != null
  }
  configs_by_type = {
    applications    = { for path, config in local.valid_configs : trimsuffix(basename(path), ".yaml") => config if startswith(path, "applications/") }
    identities      = { for path, config in local.valid_configs : trimsuffix(basename(path), ".yaml") => config if startswith(path, "identities/") }
    identity_groups = { for path, config in local.valid_configs : trimsuffix(basename(path), ".yaml") => config if startswith(path, "identity_groups/") }
    pki_auth_roles  = { for path, config in local.valid_configs : trimsuffix(basename(path), ".yaml") => config if startswith(path, "pki-auth-roles/") }
    pkiroles        = { for path, config in local.valid_configs : trimsuffix(basename(path), ".yaml") => config if startswith(path, "pkiroles/") }
  }
  applications_map = {
    for filename, config in local.configs_by_type.applications :
    config.appid => config
  }
  pki_auth_roles_map = {
    for filename, config in local.configs_by_type.pki_auth_roles :
    config.name => config
  }
  pki_roles_map = {
    for filename, config in local.configs_by_type.pkiroles :
    config.name => config
  }
  identity_groups_map = {
    for filename, config in local.configs_by_type.identity_groups :
    config.name => config
  }

  human_identities_map = {
    for filename, config in local.configs_by_type.identities :
    config.identity.name => config
    if startswith(filename, "human_")
  }
  application_identities_map = {
    for filename, config in local.configs_by_type.identities :
    config.identity.name => config
    if startswith(filename, "application_")
  }
  kubernetes_identities_map = {
    for filename, config in local.configs_by_type.identities :
    config.identity.name => config
    if startswith(filename, "kubernetes_")
  }
  human_with_pki = {
    for k, v in local.human_identities_map :
    k => v if try(v.authentication.pki, null) != null && v.authentication.pki != ""
  }
  app_with_pki = {
    for k, v in local.application_identities_map :
    k => v if try(v.authentication.pki, null) != null && v.authentication.pki != ""
  }
}