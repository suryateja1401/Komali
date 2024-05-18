 module "mys3" { 
  source = "C:/terraform_1.8.3_windows_amd64/mymodule/s3"
  bucket_name = "komali-bucket"
 } 

module "myvpc" {
    source = "C:/terraform_1.8.3_windows_amd64/mymodule/vpc"
    vpc_cidr = "10.10.0.0/16"
vpc_name = "komali"
public_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
private_subnet_cidrs = ["10.10.4.0/24", "10.10.5.0/24", "10.10.6.0/24"]
azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
igw_name = "komali-igw"
route_name = "komali-route"

}



module "myec2" {
    source = "C:/terraform_1.8.3_windows_amd64/mymodule/EC2"
ami_id = "ami-04ff98ccbfa41c9ad"
azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
server_type = "t2.micro"
keypair_name = "Keypair"
server_name = ["dev", "test", "prod"]
subnet_id = module.myvpc.subnet_id
}