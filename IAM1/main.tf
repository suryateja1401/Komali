resource "aws_iam_user" "users" {
  for_each = var.user_groups

  name = each.key
}

resource "aws_iam_user_login_profile" "users" {
  for_each = var.user_groups

  user                    = aws_iam_user.users[each.key].name
  password_reset_required = true
}

resource "aws_iam_access_key" "users" {
  for_each = var.user_groups

  user = aws_iam_user.users[each.key].name
}

resource "aws_iam_user_group_membership" "users_group_membership" {
  for_each = var.user_groups

  user   = aws_iam_user.users[each.key].name
  groups = [var.user_groups[each.key]]
}

output "user_access_key_ids" {
  value     = { for user_key, access_key in aws_iam_access_key.users : user_key => access_key.id }
  sensitive = true
}

output "user_secret_access_keys" {
  value     = { for user_key, access_key in aws_iam_access_key.users : user_key => access_key.secret }
  sensitive = true
}

output "user_passwords" {
  value     = { for user_key, login_profile in aws_iam_user_login_profile.users : user_key => login_profile.encrypted_password }
  sensitive = true
}