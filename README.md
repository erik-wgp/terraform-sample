# Terraform Sample

# Goals

This is a set of terraform configs based on terraform (v0.11.11 and updated to v0.12.10) to achieve the following goals:

- Setup a core set of AWS infrastructure (VPC, DMZ subnet, NATs, IGs, VPN servers)
- Setup individual environments (dev, staging, prod, etc) via separate configurations (and potentially authorization) which
  run on top of the core infrastructure
- Configure each environment easily by altering a simple data structure, not pasting dozens of resource stanzas

This setup would need to be modified to suit specific needs.

## What it creates

These configurations create environments for a theoretical app with web "servers", "vault" servers
which do super-secret-secure things, "admin" servers with extra access, "master" servers which manage
content, and "sidekiq" servers which run queued tasks.  These can be arranged across two subnets for
redundancy, and counts can vary between environments.

For each environment, in each availability zone, "main" and "inner" subnets are created to
potentially control access at the network level (in addition to security groups).

The core environment consists of the numerous VPC pieces, redundant VPN servers, and
an SMTP server.

# Usage

I recommend setting up a separate "scratch" AWS account before running terraform configurations
downloaded randomly on the internet.

- Copy `shared_config/shared_config.tf.sample` to `shared_config/shared_config.tf`, and modify as appropriate
- In `core/`, run `terraform init` and then `terraform apply`.  Review carefully before applying.
- Once complete, copy `shared_infra/shared_infra.tf.sample` to `shared_infra/shared_infra.tf` and set the variables to match new core resources created (use AWS console or command line, see TODO)

Now in `dev/`
- Modify the top `env_config.tf` as needed.  Adjust the counts for the different server types, RDS info, instance types, etc as desired.
- In `dev/`, run run `terraform init` and then `terraform apply`.  Review carefully before applying.

The `dev/` dir can be copied to `staging/` or `production/` or `edge/` or whatever additional
environments are needed (do not copy the terraform.* or .terraform files), presumably with production
having greater counts and larger instance types.

# CAVEATS

This set of configurations is intended for experienced AWS users who understand
the resources being created, how to manage them, and how much they cost.  This also assumes
some understanding of terraform.

These are meant as a working example which could be adapted in part or total by others.

The processes of sanitizing this for release may have led to some subtle errors.

Server configuration would be handled separately via some other process (ansible, chef, etc)

# TODO
- output or import core infrastructure automagically instead of hand creating shared_infra
- make VPC peer setup optional
- research and document IAM setup for environments (possibly create via core?)
