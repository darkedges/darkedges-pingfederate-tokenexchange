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
