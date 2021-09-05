output "id" {
  value = oci_core_instance.Superset.*.id
}

output "public_ip" {
  value = join(", ", oci_core_instance.Superset.*.public_ip)
}

output "superset_admin_username" {
  value = var.superset_admin_username
}

output "superset_admin_password" {
  value = var.superset_admin_password
}

output "superset_name" {
  value = var.superset_name
}

output "superset_password" {
  value = var.superset_password
}

output "superset_schema_name" {
  value = var.superset_schema
}

output "superset_host_name" {
  value = oci_core_instance.Superset.*.display_name
}
