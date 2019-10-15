variable "env_prefix" {}

variable "db_conf" { type = "map" }
variable "username" {}
variable "security_group" {}
variable "rds_engine_version" { default = "5.6" }
variable "rds_instance_type"  { default = "t2.micro" }
variable "subnet_ids" { type = "list" }

variable "vault_conf" { type = "map" }
variable "vault_security_group" {}
variable "rds_vault_engine_version" { default = "5.6" }
variable "rds_vault_instance_type"  { default = "t2.micro" }
variable "vault_subnet_ids" { type = "list" }

resource "aws_db_instance" "main" {
   identifier             = "${var.env_prefix}-db"
   username               = "${var.username}"
   password               = "${var.db_conf["password"]}"
  
   allocated_storage      = "${var.db_conf["storage"]}"
   engine                 = "mysql"
   engine_version         = "${var.rds_engine_version}"
   instance_class         = "${var.db_conf["type"]}"
  
   vpc_security_group_ids = [ "${var.security_group}" ]
   db_subnet_group_name   = "${aws_db_subnet_group.main.id}"

   final_snapshot_identifier = "${var.env_prefix}-db-final"

   lifecycle { create_before_destroy = true }
}

resource "aws_db_subnet_group" "main" {
   name        = "${var.env_prefix}-main"
   subnet_ids  = var.subnet_ids
   lifecycle { create_before_destroy = true }
}


resource "aws_db_instance" "vault" {
   identifier             = "${var.env_prefix}-db-vault"
   username               = "${var.username}"  
   password               = "${var.vault_conf["password"]}"

   allocated_storage      = "${var.vault_conf["storage"]}"
   engine                 = "mysql"
   engine_version         = "${var.rds_engine_version}"
   instance_class         = "${var.vault_conf["type"]}"

   vpc_security_group_ids = [ "${var.vault_security_group}" ]
   db_subnet_group_name   = "${aws_db_subnet_group.vault.id}"

   final_snapshot_identifier = "${var.env_prefix}-db-vault-final"

   lifecycle { create_before_destroy = true }
}

resource "aws_db_subnet_group" "vault" {
   name        = "${var.env_prefix}-vault"
   subnet_ids  = var.vault_subnet_ids
   lifecycle { create_before_destroy = true }
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
