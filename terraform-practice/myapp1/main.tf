resource "aws_vpc" "main" {
 cidr_block = var.vpc_cidr
 tags = {
   Name = var.vpc_name
 }
}

resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}
 
resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
vpc_id     = aws_vpc.main.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}

resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main.id
 
 tags = {
   Name = var.igw_name
 }
}

resource "aws_route_table" "second_rt" {
 vpc_id = aws_vpc.main.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
   Name = var.route_name
}
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.second_rt.id
}


resource "aws_instance" "myec2" {
  count = length(var.azs)
  ami           = var.ami_id
  instance_type = var.server_type
  key_name = var.keypair_name
  associate_public_ip_address = true
  subnet_id   = aws_subnet.public_subnets[count.index].id
  availability_zone = element(var.azs, count.index)
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  
  tags = {
    Name = element(var.server_name,count.index)
  }
}

