
###
### Main
###

resource "aws_subnet" "main" {
   cidr_block        = "${cidrsubnet(local.c.vpc.cidr, 8, var.main_subnet)}"
   vpc_id            = "${local.ic.vpc_id}"
   availability_zone = "${var.availability_zone}"

   tags = {
      Name = "${var.az_short}-main"
   }
}

resource "aws_route_table" "main" {
   vpc_id = "${local.ic.vpc_id}"

   route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = "${var.nat_id}"
   }

   route {
      ### peering admin routes
      cidr_block = "${local.c.adm_peering.cidr}"
      vpc_peering_connection_id = "${local.ic.adm_peering_id}"
   }

   ### routes to VPN instances
   route {
      cidr_block = "${cidrsubnet(local.c.vpn.cidr, 8, 1)}"
      instance_id = "${local.ic.vpn_1d}"
   }

   route {
      cidr_block = "${cidrsubnet(local.c.vpn.cidr, 8, 101)}"
      instance_id = "${local.ic.vpn_1e}"
   }

   tags = {
      Name = "${var.env_prefix}-main"
   }
}

resource "aws_route_table_association" "main" {
   subnet_id      = "${aws_subnet.main.id}"
   route_table_id = "${aws_route_table.main.id}"
}

###
### Inner
###

resource "aws_subnet" "inner" {
   cidr_block        = "${cidrsubnet(local.c.vpc.cidr, 8, var.inner_subnet)}"
   vpc_id            = "${local.ic.vpc_id}"
   availability_zone = "${var.availability_zone}"

   tags = {
      Name = "${var.az_short}-inner"
   }
}

resource "aws_route_table" "inner" {
   vpc_id = "${local.ic.vpc_id}"

   route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = "${var.nat_id}"
   }

   route {
      cidr_block = "${local.c.adm_peering.cidr}"
      vpc_peering_connection_id = "${local.ic.adm_peering_id}"
   }

   route {
      cidr_block = "${cidrsubnet(local.c.vpn.cidr, 8, 1)}"
      instance_id = "${local.ic.vpn_1d}"
   }

  route {
      cidr_block = "${cidrsubnet(local.c.vpn.cidr, 8, 101)}"
      instance_id = "${local.ic.vpn_1e}"
   }

   tags = {
      Name = "${var.env_prefix}-inner"
   }
}

resource "aws_route_table_association" "inner" {
   subnet_id      = "${aws_subnet.inner.id}"
   route_table_id = "${aws_route_table.inner.id}"
}
