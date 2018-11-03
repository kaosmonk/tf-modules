output "master_instance_sql_ipv4" {
  value       = "${google_sql_database_instance.master.ip_address.0.ip_address}"
  description = "The IPv4 address assigned for master"
}

output "generated_user_password" {
  description = "The auto generated default user password if no input password was provided"
  value       = "${random_id.user-password.hex}"
  sensitive   = true
}
