resource "random_id" "server" {
byte_length = 2
}
resource "aws_s3_bucket" "mys3" {
  bucket = "${var.bucket_name}-${random_id.server.hex}"
  tags = {
    Name        = "${var.bucket_name}-${random_id.server.hex}"
  
  }
}


