
# pre-built network env
variable "main_subnet" {}
variable "inner_subnet" {}
variable "nat_id" {}

variable "availability_zone" {}
variable "az_short" {}
variable "az_long" {}

variable "env_prefix" {}

module "shared_infra" {
    source = "../../shared_infra"
}

module "shared_config" {
    source = "../../shared_config"
}

# this is a little cleaner visually for access
locals {
   ic  = "${module.shared_infra.infra_conf}"
   c   = "${module.shared_config.all_conf}"
}