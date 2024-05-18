resource "aws_instance" "myec2" {
  count = length(var.azs)
  ami           = var.ami_id
  instance_type = var.server_type
  key_name = var.keypair_name
  associate_public_ip_address = true
  subnet_id = element(var.subnet_id, count.index)
  tags = {
    Name = element(var.server_name, count.index)
  }
  availability_zone = element(var.azs, count.index)
  
}

