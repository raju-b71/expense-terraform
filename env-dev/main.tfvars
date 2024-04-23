env = "dev"
instance_type = "t3.micro"
zone_id = "Z0973896Y2YOE63MZMJ"

#vpc
vpc_cidr_block = "10.10.0.0/24"

default_vpc_id = "vpc-084e78a916ca55ff1"
default_vpc_cidr = "172.31.0.0/16"
default_route_table_id = "rtb-0de02e91b7a537727"
frontend_subnets = ["10.10.0.0/27", "10.10.0.32/27"]
backend_subnets = ["10.10.0.64/27", "10.10.0.96/27"]
db_subnets = ["10.10.0.128/27", "10.10.0.160/27"]
public_subnets = ["10.10.0.192/27","10.10.0.224/27"]
availability_zones = ["us-east-1a", "us-east-1b"]
bastion_nodes = ["172.31.95.163/32"]
prometheus_nodes = ["172.31.35.105/32"]