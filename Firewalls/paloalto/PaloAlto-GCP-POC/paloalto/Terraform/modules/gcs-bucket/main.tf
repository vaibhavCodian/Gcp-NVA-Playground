resource "google_storage_bucket" "bucket" {
  for_each      = var.buckets
  project       = var.project_id
  name          = each.key
  location      = var.location
  force_destroy = each.value.force_destroy
  storage_class = each.value.storage_class
}
