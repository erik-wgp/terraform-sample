
resource "aws_vpc" "main" {
   cidr_block = "${local.c.vpc.cidr}"
   enable_dns_hostnames = true

   tags = { Name = "${local.c.client.short}-${local.c.region}" }
}

resource "aws_internet_gateway" "current" {
   vpc_id = "${aws_vpc.main.id}"
   tags   = { Name = "${local.c.client.short}-ig" }
}

resource "aws_route_table" "dmz" {
   vpc_id = "${aws_vpc.main.id}"

   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.current.id}"
   }

   route {
      cidr_block = "${local.c.adm_peering.cidr}"
      vpc_peering_connection_id = "${aws_vpc_peering_connection.adm_pcx.id}"
   }

   route {
      #"${local.c.vpn.cidr_prefix}.1.0/24"
      cidr_block = "${cidrsubnet(local.c.vpn.cidr, 8, 1)}"
      instance_id = "${aws_instance.vpn1d.id}"
   }

   route {
      cidr_block = "${cidrsubnet(local.c.vpn.cidr, 8, 101)}"
      instance_id = "${aws_instance.vpn1e.id}"
   }

   tags = {
      Name = "${local.c.client.short}-dmz"
   }
}

resource "aws_security_group" "base" {
   name        = "${local.c.client.short}-base"
   description = "${local.c.client.short}-base"
   vpc_id      = "${aws_vpc.main.id}"
   tags        = { Name = "${local.c.client.short}-base" }  

   ingress {
      from_port = 0
      to_port = 0
      protocol = -1
      cidr_blocks = "${local.c.vpc.admin_ips}"
   }

   egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_security_group" "dmz-vpn" {
   name        = "${local.c.client.short}-dmz-vpn"
   description = "${local.c.client.short}-dmz-vpn"
   tags        = { Name = "${local.c.client.short}-dmz-vpn" }
   vpc_id      = "${aws_vpc.main.id}"

   ingress {
      from_port   = "${local.c.vpn.listen_port}"
      to_port     = "${local.c.vpn.listen_port}"
      protocol    = 17
      cidr_blocks = "${local.c.vpn.allow_ips}"
   }

   egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_security_group" "dmz-vpn-dynamic" {
   name        = "${local.c.client.short}-dmz-vpn-dynamic"
   description = "${local.c.client.short}-dmz-vpn-dynamic"
   tags        = { Name = "${local.c.client.short}-dmz-vpn-dynamic" }
   vpc_id      = "${aws_vpc.main.id}"

   ingress {
      from_port   = "${local.c.vpn.listen_port}"
      to_port     = "${local.c.vpn.listen_port}"
      protocol    = 17
      cidr_blocks = "${local.c.vpn.allow_ips}"
   }

   egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
   lifecycle {
      ignore_changes = [ "ingress" ]
   }
}

resource "aws_security_group" "dmz-special" {
   name        = "${local.c.client.short}-dmz-special"
   description = "${local.c.client.short}-dmz-special"
   tags        = { Name = "${local.c.client.short}-dmz-special" }
   vpc_id      = "${aws_vpc.main.id}"

   ingress {
      from_port = 22
      to_port = 22
      protocol = 6
      cidr_blocks = "${local.c.vpn.special_ips}"
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_security_group" "dmz-smtp" {
   name        = "${local.c.client.short}-dmz-smtp"
   description = "${local.c.client.short}-dmz-smtp"
   tags        = { Name = "${local.c.client.short}-dmz-smtp" }

   vpc_id      = "${aws_vpc.main.id}"

   ingress {
      from_port = 587
      to_port = 587
      protocol = 6
      cidr_blocks = [ "0.0.0.0/0" ]
   }

   ingress {
      from_port = 25
      to_port = 25
      protocol = 6
      cidr_blocks = [ "0.0.0.0/0" ]
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

module "dmz-d" {
      source     = "./dmz"
      zone       = "us-east-1d"
      zone_short = "e1d"
      client     = "${local.c.client.short}"
      vpc_id     = "${aws_vpc.main.id}"
      vpc_cidr   = "${local.c.vpc.cidr}"
      vpc_ig     = "${aws_internet_gateway.current.id}"
      ami        = "${local.c.default_ami}"
      dmz_subnet = "1"
      dmz_route_table_id = "${aws_route_table.dmz.id}"
}

module "dmz-e" {
      source     = "./dmz"
      zone       = "us-east-1e"
      zone_short = "e1e"
      client     = "${local.c.client.short}"
      vpc_id     = "${aws_vpc.main.id}"
      vpc_cidr   = "${local.c.vpc.cidr}"
      vpc_ig     = "${aws_internet_gateway.current.id}"
      ami        = "${local.c.default_ami}"
      dmz_subnet = "101"
      dmz_route_table_id = "${aws_route_table.dmz.id}"
}

resource "aws_vpc_peering_connection" "adm_pcx" {
   peer_owner_id = "${local.c.adm_peering.owner}"
   peer_vpc_id   = "${local.c.adm_peering.vpc_id}"
   vpc_id        = "${aws_vpc.main.id}"
}

resource "aws_instance" "vpn1d" {
      subnet_id         = "${module.dmz-d.subnet_dmz}"
      instance_type     = "t2.micro"
      ami               = "${local.c.default_ami}"
      source_dest_check = false

      vpc_security_group_ids = [ "${aws_security_group.dmz-vpn.id}", "${aws_security_group.dmz-special.id}" ]
      lifecycle { create_before_destroy = true }

      tags = {
         Name = "${local.c.client.short}-vpn-e1d"
         Client = "${local.c.client.tag}"
      }
}

resource "aws_eip" "vpn1d" {
   instance = "${aws_instance.vpn1d.id}"
   tags     = { Name = "${local.c.client.short}-vpn-e1d" }
   vpc      = true
}

resource "aws_instance" "vpn1e" {
      subnet_id         = "${module.dmz-e.subnet_dmz}"
      instance_type     = "t2.micro"
      ami               = "${local.c.default_ami}"
      source_dest_check = false

      vpc_security_group_ids = [ "${aws_security_group.dmz-vpn.id}", "${aws_security_group.dmz-special.id}" ]
      lifecycle { create_before_destroy = true }
      tags = {
         Name = "${local.c.client.short}-vpn-e1e"
         Client = "${local.c.client.tag}"
      }
}

resource "aws_eip" "vpn1e" {
   instance = "${aws_instance.vpn1e.id}"
   tags     = { Name = "${local.c.client.short}-vpn-e1e" }
   vpc      = true
}

resource "aws_instance" "smtp" {
      subnet_id     = "${module.dmz-e.subnet_dmz}"
      instance_type = "t2.nano"
      ami           = "${local.c.default_ami}"

      vpc_security_group_ids = [ "${aws_security_group.dmz-smtp.id}", "${aws_security_group.dmz-special.id}" ]
      lifecycle { create_before_destroy = true }
      tags = {
         Name = "${local.c.client.short}-smtp-e1e"
         Client = "${local.c.client.tag}"
      }
}

resource "aws_eip" "smtp" {
   instance = "${aws_instance.smtp.id}"
   tags     = { Name = "${local.c.client.short}-smtp-e1e" }
   vpc      = true
}
