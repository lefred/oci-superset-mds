output "superset_public_ip" {
  value = "http://${module.superset.public_ip}"
}

output "superset_admin_username" {
  value = module.superset.superset_admin_username
}

output "superset_admin_password" {
  value = module.superset.superset_admin_password
  sensitive = true
}

output "superset_db_user" {
  value = var.superset_name
}

output "superset_db_password" {
  value = var.superset_password
  sensitive = true
}

output "mds_instance_ip" {
  value =  module.mds-instance.private_ip
}

output "ssh_private_key" {
  value = local.private_key_to_show
  sensitive = true
}
