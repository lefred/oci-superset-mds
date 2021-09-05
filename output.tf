output "superset_public_ip" {
  value = module.superset.public_ip
}

output "superset_admin_username" {
  value = module.superset.superset_admin_username
}

output "superset_admin_password" {
  value = module.superset.superset_admin_password
}

output "superset_db_user" {
  value = module.superset.superset_name
}

output "superset_schema" {
  value = module.superset.superset_schema_name
}

output "superset_db_password" {
  value = var.superset_password
}

output "mds_instance_ip" {
  value = module.mds-instance.private_ip
}

output "ssh_private_key" {
  value = local.private_key_to_show
}
