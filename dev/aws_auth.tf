
# these can be changes to an IAM user which is more limited
provider "aws" {
   region                  = "${local.c.region}"
   shared_credentials_file = "${local.c.aws.credentials_file}"
   profile                 = "${local.c.aws.profile}"
}
