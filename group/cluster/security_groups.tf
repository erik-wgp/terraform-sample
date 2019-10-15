

resource "aws_security_group" "admin" {
   name        = "${var.env_prefix}-admin"
   description = "${var.env_prefix}-admin"
   vpc_id      = "${local.ic.vpc_id}"

   ingress {
      from_port = 22
      to_port = 22
      protocol = 6
      cidr_blocks = local.c.vpc.admin_ips
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_security_group" "app" {
   name        = "${var.env_prefix}-app"
   description = "${var.env_prefix}-app"
   vpc_id      = "${local.ic.vpc_id}"

   ingress {
      from_port = 22
      to_port = 22
      protocol = 6
      security_groups = [ "${aws_security_group.admin.id}" ]
   }

   ingress {
      from_port = 80
      to_port = 80
      protocol = 6
      security_groups = [ "${aws_security_group.admin.id}" ]
   }

   ingress {
      from_port = 443
      to_port = 443
      protocol = 6
      security_groups = [ "${aws_security_group.admin.id}" ]
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_security_group" "dmz-lb" {
   name        = "${var.env_prefix}-dmz-lb"
   description = "${var.env_prefix}-dmz-lb"
   vpc_id      = "${local.ic.vpc_id}"

   ingress {
      from_port = 80
      to_port = 80
      protocol = 6
      cidr_blocks =  [ "0.0.0.0/0" ]
   }

   ingress {
      from_port = 443
      to_port = 443
      protocol = 6
      cidr_blocks =  [ "0.0.0.0/0" ]
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_security_group" "vault-lb" {
   name        = "${var.env_prefix}-vault-lb"
   description = "${var.env_prefix}-vault-lb"
   vpc_id      = "${local.ic.vpc_id}"

   ingress {
      from_port = 443
      to_port = 443
      protocol = 6
      security_groups = [ "${aws_security_group.app.id}" ]
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_security_group" "mysql" {
   name        = "${var.env_prefix}-mysql"
   description = "${var.env_prefix}-mysql"
   vpc_id      = "${local.ic.vpc_id}"

   ingress {
      from_port = 3306
      to_port = 3306
      protocol = 6
      security_groups = [ "${aws_security_group.app.id}", "${aws_security_group.admin.id}" ]
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_security_group" "vault-mysql" {
   name        = "${var.env_prefix}-vault-mysql"
   description = "${var.env_prefix}-vault-mysql"
   vpc_id      = "${local.ic.vpc_id}"

   ingress {
      from_port = 3306
      to_port = 3306
      protocol = 6
      security_groups = [ "${aws_security_group.app.id}", "${aws_security_group.admin.id}" ]
  }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_security_group" "base" {
   name        = "${var.env_prefix}-base"
   description = "${var.env_prefix}-base"
   vpc_id      = "${local.ic.vpc_id}"

   ingress {
      from_port = 443
      to_port = 443
      protocol = 6
      security_groups = [ "${aws_security_group.monitor.id}" ]
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_security_group" "server" {
   name        = "${var.env_prefix}-server"
   description = "${var.env_prefix}-server"
   vpc_id      = "${local.ic.vpc_id}"

   ingress {
      from_port = 80
      to_port = 80
      protocol = 6
      security_groups = [ "${aws_security_group.dmz-lb.id}" ]
   }

   ingress {
      from_port = 443
      to_port = 443
      protocol = 6
      security_groups = [ "${aws_security_group.dmz-lb.id}" ]
   }

   #! alternate ports?

   # admin server
   ingress {
      from_port = 0
      to_port = 0
      protocol = -1
      security_groups = [ "${aws_security_group.admin.id}" ]
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_security_group" "vault" {
   name        = "${var.env_prefix}-vault"
   description = "${var.env_prefix}-vault"
   vpc_id      = "${local.ic.vpc_id}"

   ingress {
      from_port = 80
      to_port = 80
      protocol = 6
      security_groups = [ "${aws_security_group.vault-lb.id}" ]
   }

   ingress {
      from_port = 443
      to_port = 443
      protocol = 6
      security_groups = [ "${aws_security_group.vault-lb.id}" ]
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_security_group" "monitor" {
   name        = "${var.env_prefix}-monitor"
   description = "${var.env_prefix}-monitor"
   vpc_id      = "${local.ic.vpc_id}"

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_security_group" "radius" {
   name        = "${var.env_prefix}-radius"
   description = "${var.env_prefix}-radius"
   vpc_id      = "${local.ic.vpc_id}"

   ingress {
      from_port = 6379
      to_port = 6380
      protocol = 6
      security_groups = [ "${aws_security_group.app.id}" ]
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}
