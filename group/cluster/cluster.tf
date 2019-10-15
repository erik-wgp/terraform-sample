variable "env_prefix" {}

### TODO rework routes so clusters can't talk to each other

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