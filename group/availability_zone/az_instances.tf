
variable server_conf {
   type = "map"
   default = {}
}

variable sg_map { type = "map" }

locals {

   # map which SG names go to which server types
   sg_assignments = {
      server  = [ "global", "base", "app", "server" ]
      vault   = [ "global", "base", "inner" ]
      admin   = [ "global", "base", "inner", "admin" ]
      master  = [ "global", "base", "app", "server" ]
      sidekiq = [ "global", "base", "app" ]
   }

   # map of which subnet different servers should be placed in
   subnet_assignments = {
      server  = "${aws_subnet.main.id}"
      vault   = "${aws_subnet.inner.id}"
      admin   = "${aws_subnet.inner.id}"
      master  = "${aws_subnet.main.id}"
      sidekiq = "${aws_subnet.main.id}"
   }
}

### Not sure how to DRY this

module "servers" {
   source = "../single_instance"   
   server_type = "server"

   subnet_assignments = local.subnet_assignments
   sg_assignments     = local.sg_assignments
   sg_map             = var.sg_map
   server_conf        = "${var.server_conf}"
   env_prefix         = var.env_prefix
   az_short           = var.az_short
}

module "admin" {
   source = "../single_instance"   
   server_type = "admin"

   subnet_assignments = local.subnet_assignments
   sg_assignments     = local.sg_assignments
   sg_map             = var.sg_map
   server_conf        = "${var.server_conf}"
   env_prefix         = var.env_prefix
   az_short           = var.az_short
}

module "master" {
   source = "../single_instance"   
   server_type = "master"

   subnet_assignments = local.subnet_assignments
   sg_assignments     = local.sg_assignments
   sg_map             = var.sg_map
   server_conf        = "${var.server_conf}"
   env_prefix         = var.env_prefix
   az_short           = var.az_short
}

module "vault" {
   source = "../single_instance"   
   server_type = "vault"

   subnet_assignments = local.subnet_assignments
   sg_assignments     = local.sg_assignments
   sg_map             = var.sg_map
   server_conf        = "${var.server_conf}"
   env_prefix         = var.env_prefix
   az_short           = var.az_short
}

module "sidekiq" {
   source = "../single_instance"   
   server_type = "sidekiq"

   subnet_assignments = local.subnet_assignments
   sg_assignments     = local.sg_assignments
   sg_map             = var.sg_map
   server_conf        = "${var.server_conf}"
   env_prefix         = var.env_prefix
   az_short           = var.az_short
}

