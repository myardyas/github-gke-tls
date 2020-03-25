resource "google_dns_managed_zone" "my-zone" {
  name        = "myardyas.online"
  dns_name    = "myardyas.online."
  description = "My DNS zone"
}
