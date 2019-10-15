
variable server_type { }

variable subnet_assignments {}
variable sg_assignments {}
variable sg_map {}
variable server_conf {}

variable env_prefix {}
variable az_short {}

resource "aws_instance" "current" {
    subnet_id     = "${var.subnet_assignments[var.server_type]}"

    count         = "${lookup(var.server_conf, "${var.server_type}_count", lookup(var.server_conf, "default_count"))}"
    instance_type = "${lookup(var.server_conf, "${var.server_type}_type",  lookup(var.server_conf, "default_type"))}"
    ami           = "${lookup(var.server_conf, "${var.server_type}_ami",   lookup(var.server_conf, "default_ami"))}"  

    vpc_security_group_ids = matchkeys( values(var.sg_map), 
                                          keys(var.sg_map),
                                          var.sg_assignments[var.server_type] )

    lifecycle { create_before_destroy = true }

    tags = {
        Name = "${var.env_prefix}-${var.server_type}-${var.az_short}${count.index + 1}"
        Client = "${local.c.client.tag}"
    }
}

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
