resource "google_dns_managed_zone" "my-zone" {
  name        = "zpm-zone"
  dns_name    = "zpm.myardyas.online."
  description = "My DNS zone"
}
