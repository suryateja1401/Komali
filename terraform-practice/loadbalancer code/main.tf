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

resource "aws_security_group" "my-sg" {
 name        = "my-sg"
 description = "Allow ssh and http to servers"
 vpc_id      = aws_vpc.main.id

ingress {
   description = "ssh ingress"
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }

ingress {
   description = "http ingress"
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }

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

resource "aws_lb" "myalb" {
  name               = var.load_name
  internal           = false
  load_balancer_type = var.load_type
  security_groups    = [aws_security_group.my-sg.id]
  subnets            = tolist(aws_subnet.public_subnets[*].id)

  enable_deletion_protection = true

  tags = {
    Name = var.load_name
  }
}


resource "aws_lb_target_group" "my-tg" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200-299"
  }

  tags = {
    Name = "alb-tg"
  }
}

resource "aws_lb_listener" "mylistner" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-tg.arn
  }
}

output "alb_dns_name" {
  description = "The DNS name of the ALB."
  value       = aws_lb.myalb.dns_name
}

output "alb_arn" {
  description = "The ARN of the ALB."
  value       = aws_lb.myalb.arn
}

output "target_group_arn" {
  description = "The ARN of the target group."
  value       = aws_lb_target_group.my-tg.arn
}
