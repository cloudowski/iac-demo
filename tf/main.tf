terraform {
  backend "s3" {
    bucket         = "terraform-state-iac-demo"
    key            = "iac-demo"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-iac-demo"
  }

  required_version = ">= 0.10.0"
}

provider "aws" {
  region = "${var.region}"
}

//  Create the OpenShift cluster using our module.
module "vpc" {
  source       = "git::https://github.com/cloudowski/terraform-vpc.git"
  cidr         = "10.0.0.0/16"
  code_version = "${var.code_version}"
  name         = "iac-demo-${var.env}"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}

//  Create an SSH keypair
resource "aws_key_pair" "keypair" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}

//  Security group which allows SSH access to a host.
resource "aws_security_group" "iac-demo-ssh" {
  name        = "iac-demo-ssh-${var.env}"
  description = "Security group that allows public ingress over SSH."
  vpc_id      = "${module.vpc.vpc-id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_access_cidr}"]
  }

  tags {
    Env = "${var.env}"
  }
}

//  Security group which allows access external service via http/https
resource "aws_security_group" "iac-demo-egress" {
  name        = "iac-demo-egress-${var.env}"
  description = "Security group that allows egress over HTTP/HTTPS."
  vpc_id      = "${module.vpc.vpc-id}"

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Env = "${var.env}"
  }
}

data "template_file" "user-data" {
  template = "${file("${path.module}/files/user-data.sh")}"
}

resource "aws_instance" "myapp" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.amisize}"
  subnet_id     = "${element(module.vpc.public-subnet-ids, 0)}"
  user_data     = "${data.template_file.user-data.rendered}"

  root_block_device {
    volume_size = 10
  }

  vpc_security_group_ids = [
    "${aws_security_group.iac-demo-ssh.id}",
    "${aws_security_group.iac-demo-egress.id}",
  ]

  key_name = "${aws_key_pair.keypair.key_name}"

  tags {
    Name        = "myapp-${var.env}"
    Env         = "${var.env}"
    Role        = "app"
    CodeVersion = "${var.code_version}"
  }
}
