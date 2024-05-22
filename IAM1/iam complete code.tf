terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    pgp = {
      source = "ekristen/pgp"
    }
  }
}

locals {
  users = {
    "Praveen" = {
      name  = "Praveen"
      email = "praveen.menige@gmail.com"
    },
    "Shiva" = {
      name  = "Shiva"
      email = "jane.smith@example.com"
    },
    "Vijay" = {
      name  = "Vijay"
      email = "alice.jones@example.com"
    },
    "Gopal" = {
      name  = "Gopal"
      email = "bob.brown@example.com"
    },
    "eve.williams" = {
      name  = "Eve Williams"
      email = "eve.williams@example.com"
    },
    "Rahul" = {
      name  = "Rahul"
      email = "Rahul.brown@example.com"
    }
  }

  user_groups = {
    "Praveen" = "testing"
    "Shiva" = "devops"
    "Vijay" = "devops"
    "Gopal" = "testing"
    "eve.williams" = "devops"
    "Rahul" = "developer"
  }
}

resource "aws_iam_user" "user" {
  for_each = local.users

  name          = each.key
  force_destroy = false
}

resource "aws_iam_access_key" "user_access_key" {
  for_each = local.users

  user       = each.key
  depends_on = [aws_iam_user.user]
}

resource "pgp_key" "user_login_key" {
  for_each = local.users

  name    = each.value.name
  email   = each.value.email
  comment = "PGP Key for ${each.value.name}"
}

resource "aws_iam_user_login_profile" "user_login" {
  for_each = local.users

  user                    = each.key
  pgp_key                 = pgp_key.user_login_key[each.key].public_key_base64
  password_reset_required = true

  depends_on = [aws_iam_user.user, pgp_key.user_login_key]
}

data "pgp_decrypt" "user_password_decrypt" {
  for_each = local.users

  ciphertext          = aws_iam_user_login_profile.user_login[each.key].encrypted_password
  ciphertext_encoding = "base64"
  private_key         = pgp_key.user_login_key[each.key].private_key
}

resource "aws_iam_group_membership" "group_membership" {
  for_each = {
    for group in distinct(values(local.user_groups)) :
    group => [for user, user_group in local.user_groups : user if user_group == group]
  }

  name  = "${each.key}-membership"
  group = each.key
  users = each.value

  depends_on = [aws_iam_user.user]
}

output "credentials" {
  value = {
    for k, v in local.users : k => {
      "key"      = aws_iam_access_key.user_access_key[k].id
      "secret"   = aws_iam_access_key.user_access_key[k].secret
      "password" = data.pgp_decrypt.user_password_decrypt[k].plaintext
    }
  }
  sensitive = true
}
