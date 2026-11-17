resource "nexus_security_anonymous" "system" {
  enabled    = true
  realm_name = "NexusAuthorizingRealm"
  user_id    = "anonymous"

  depends_on = [
    nexus_security_role.anonymous
  ]
}
