
module "cluster" {
   source = "../group/cluster"
   env_prefix = "${local.c.client.short}-${var.current_env}"
}

module "az-d" {
   source = "../group/availability_zone"

   availability_zone = "us-east-1d"
   env_prefix        = "${local.c.client.short}-${var.current_env}"
   az_short          = "1d"
   az_long           = "${local.c.client.short}-${var.current_env}-1d"

   main_subnet       = "${var.main_subnet_d}"
   inner_subnet      = "${var.inner_subnet_d}"

   server_conf       = "${var.server_conf_1d}"
   nat_id            = "${local.ic.nat_1d}"
   sg_map            = "${module.cluster.sg_map}"
}

module "az-e" {
   source = "../group/availability_zone"

   availability_zone = "us-east-1e"
   env_prefix        = "${local.c.client.short}-${var.current_env}"
   az_short          = "1e"
   az_long           = "${local.c.client.short}-${var.current_env}-1e"

   main_subnet       = "${var.main_subnet_e}"
   inner_subnet      = "${var.inner_subnet_e}"

   server_conf       = "${var.server_conf_1e}"
   nat_id            = "${local.ic.nat_1e}"
   sg_map            = "${module.cluster.sg_map}"
}

module "rds" {
   source = "../group/rds"

   env_prefix = "${local.c.client.short}-${var.current_env}"
   username   = "${local.c.client.short}_${var.current_env}_root"

   db_conf = "${var.db_conf}"

   subnet_ids     = [ "${module.az-d.main_subnet}", "${module.az-e.main_subnet}" ]
   security_group = "${module.cluster.sg_map["mysql"]}"

   vault_conf = "${var.db_conf}"
   vault_subnet_ids     = [ "${module.az-d.inner_subnet}", "${module.az-e.inner_subnet}" ]
   vault_security_group = "${module.cluster.sg_map["vault-mysql"]}"
}

module "shared_infra" {
   source = "../shared_infra"
}

module "shared_config" {
   source = "../shared_config"
}

# this is a little cleaner visually for access
locals {
   ic  = "${module.shared_infra.infra_conf}"
   c   = "${module.shared_config.all_conf}"
}