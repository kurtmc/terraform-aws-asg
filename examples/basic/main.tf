terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = ">= 2.17"
  region  = "${var.region}"
}

data "aws_vpc" "main" {
  default = true
}

data "aws_subnet_ids" "main" {
  vpc_id = data.aws_vpc.main.id
}

data "aws_ami" "linux2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami*gp2"]
  }
}

module "asg" {
  source       = "../../"
  name_prefix  = var.name_prefix
  vpc_id       = data.aws_vpc.main.id
  subnet_ids   = data.aws_subnet_ids.main.ids
  instance_ami = data.aws_ami.linux2.id

  tags = {
    terraform   = "True"
    environment = "dev"
  }
}
