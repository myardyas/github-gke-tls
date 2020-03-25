resource "google_dns_managed_zone" "my-zone" {
  name        = "zpm-zone"
  dns_name    = "myardyas.online."
  description = "My DNS zone"
}
