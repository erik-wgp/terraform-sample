
variable "client"       {}
variable "zone"         {}
variable "zone_short"   {}
variable "vpc_id"       {}
variable "vpc_cidr"     {}
variable "vpc_ig"       {}
variable "ami"          {}
variable "dmz_subnet"   {}

variable "dmz_route_table_id" {}

resource "aws_subnet" "dmz" {
   cidr_block              = "${cidrsubnet(var.vpc_cidr, 8, var.dmz_subnet)}"
   vpc_id                  = "${var.vpc_id}"
   availability_zone       = "${var.zone}"
   map_public_ip_on_launch = true

   tags = {
      Name = "${var.client}-dmz-${var.zone_short}"
   }
}

resource "aws_eip" "nat_ip" {
   vpc  = true
   tags = { Name = "${var.client}-nat-${var.zone_short}" }

}

resource "aws_route_table_association" "dmz" {
   subnet_id      = "${aws_subnet.dmz.id}"
   route_table_id = "${var.dmz_route_table_id}"
}

resource "aws_nat_gateway" "current" {
   subnet_id = "${aws_subnet.dmz.id}"
   allocation_id = "${aws_eip.nat_ip.id}"
}

