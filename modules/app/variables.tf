variable "instance_type" {}
variable "component" {}
variable "env" {}
variable "zone_id" {}
variable "vault_token" {}
variable "vpc_id" {}
variable "subnets" {}
variable "lb_type" {       #we provide this because mysql will not fqil looing for value
  default = null
}
variable "lb_needed" {
  default = false
}
variable "lb_subnets" {
  default = null

}
