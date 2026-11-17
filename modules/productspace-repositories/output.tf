#output "User" {
#  value = var.project.user_manual_create ? nexus_security_user.sa-user.userid : "No User Manual Created"
#  sensitive = true
#}
#
#output "Password" {
#  value = var.project.user_manual_create ? nexus_security_user.sa-user.password : "No User Manual Created"
#  sensitive = true
#}
