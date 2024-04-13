#module "frontend" {
 # depends_on = [module.backend]
  #source = "./modules/app"
  #instance_type = var.instance_type
  #component = "frontend"
  #ssh_user = var.ssh_pass
  #ssh_pass = var.ssh_pass
  #env = var.env
  #zone_id = var.zone_id
#}

#module "backend" {
 # depends_on = [module.mysql]
   #source = "./modules/app"
 # instance_type = var.instance_type
 # component = "backend"
 # ssh_user = var.ssh_pass
 # ssh_pass = var.ssh_pass
 # env = var.env
 # zone_id = var.zone_id
#}
module "mysql" {
  source = "./modules/app"
  instance_type = var.instance_type
  component = "mysql"
  ssh_user = jsondecode(data.vault_generic_secret.ssh.data_json).user
  ssh_pass = jsondecode(data.vault_generic_secret.ssh.data_json).pass
  env = var.env
  zone_id = var.zone_id
}


