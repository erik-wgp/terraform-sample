
output "sg_map" {
    value = {
        "global"       = "${local.ic.base_sg}"
		"base"         = "${aws_security_group.base.id}"
		"server"       = "${aws_security_group.server.id}"
		"admin"        = "${aws_security_group.admin.id}"
		"app"          = "${aws_security_group.app.id}"
		"vault-lb"     = "${aws_security_group.vault-lb.id}"
		"mysql"        = "${aws_security_group.mysql.id}"
		"vault-mysql"  = "${aws_security_group.vault-mysql.id}"
		"vault"        = "${aws_security_group.vault.id}"
		"monitor"      = "${aws_security_group.monitor.id}"
		"radius"       = "${aws_security_group.radius.id}"
		"dmz-lb"       = "${aws_security_group.dmz-lb.id}"
	}
}