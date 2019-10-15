
# Uses the standard AWS credentials setup.
# The profile will be like [default] or [scratch] in .credentials

provider "aws" {
   region                  = "${local.c.region}"
   shared_credentials_file = "${local.c.aws.credentials_file}"
   profile                 = "${local.c.aws.profile}"
}

module "shared_config" {
   source = "../shared_config"
}

# this is a little cleaner visually for access
locals {
   c  = "${module.shared_config.all_conf}"
}