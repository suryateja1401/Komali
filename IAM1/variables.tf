variable "user_groups" {
  type = map(string)
  default = {
    "Ramu" = "developer"
    "vijay" = "devops"
    "Raju" = "devops"
    "Kanth" = "developer"
    // Add more users and their corresponding groups here
  }
}