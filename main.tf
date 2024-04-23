module "frontend" {
  depends_on = [module.backend]
  source = "./modules/app"
  instance_type = var.instance_type
  component = "frontend"
  env = var.env
  zone_id = var.zone_id
  vault_token = var.vault_token
  subnets = module.vpc.frontend_subnets
  vpc_id = module.vpc.vpc_id
  lb_type = "public"
  lb_needed = true
  lb_subnets = module.vpc.public_subnets                     #we gave it because the lb needs crreate in frontendsubnets
  app_port = 80
  bastion_nodes = var.bastion_nodes
  prometheus_nodes = var.prometheus_nodes
  lb_app_port_sg_cidr = ["0.0.0.0/0"]
}


module "backend" {
  depends_on = [module.mysql]
  source = "./modules/app"
  instance_type = var.instance_type
  component = "backend"
  env = var.env
  zone_id = var.zone_id
  vault_token = var.vault_token
  subnets = module.vpc.backend_subnets
  vpc_id = module.vpc.vpc_id
  lb_type = "private"
  lb_needed = true
  lb_subnets = module.vpc.backend_subnets                                                    #for backend it needs to be in backend subnets
  app_port = 8080
  bastion_nodes = var.bastion_nodes
  prometheus_nodes = var.prometheus_nodes
  server_app_port_sg_cider = concat(module.vpc.frontend_subnets, module.vpc.backend_subnets)        #backend will acess by frontend and backend als hav lb so total 4 subnets (concat)
  lb_app_port_sg_cidr = module.vpc.frontend_subnets                                           #this can onlyacessed by frontend subnets(bacck nly aces fonr subnet)

}


module "mysql" {
  source = "./modules/app"
  instance_type = var.instance_type
  component = "mysql"
  env = var.env
  zone_id = var.zone_id
  vault_token = var.vault_token
  subnets = module.vpc.db_subnets
  vpc_id = module.vpc.vpc_id
  bastion_nodes = var.bastion_nodes
  prometheus_nodes = var.prometheus_nodes
  app_port = 3306
  server_app_port_sg_cider = module.vpc.backend_subnets              #which security group i want to allw

}


module "vpc" {
  source = "./modules/vpc"
  env = var.env
  vpc_cidr_block = var.vpc_cidr_block
  default_vpc_id = var.default_vpc_id
  default_vpc_cidr = var.default_vpc_cidr
  default_route_table_id = var.default_route_table_id
  frontend_subnets = var.frontend_subnets
  backend_subnets = var.backend_subnets
  db_subnets = var.db_subnets
  public_subnets = var.public_subnets
  availability_zones = var.availability_zones
}


