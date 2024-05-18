resource "aws_security_group" "my-sg" {
 name        = "my-sg"
 description = "Allow ssh to servers"
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
}
