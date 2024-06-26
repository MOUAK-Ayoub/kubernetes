module "windows_admin_vpc" {
  source = "github.com/MOUAK-Ayoub/terraform-modules.git/vpc-module"

  az-number     = var.az-number
  vpc-cidr      = var.vpc-cidr
  newbits       = var.newbits
  subnet-number = var.subnet-number

}



locals {
  master_instances_with_user_data = {
    for key, val in var.master_instances :

    key => {
      os_ami         = val["os_ami"],
      type           = val["type"],
      user_data      = templatefile(val["user_data_path"], {token=var.token, enable_addson=var.enable_addson}),
      tag_name       = val["tag_name"],
      instance_count = val["instance_count"]
    }

  }
  slave_instances_with_user_data = {
    for key, val in var.slave_instances :

    key => {
      os_ami = val["os_ami"],
      type   = val["type"],
      user_data = templatefile(val["user_data_path"], {
        control_node_ip = module.k8s_controle_node.vm_ips[0],
        token           = var.token
      }),
      tag_name       = val["tag_name"],
      instance_count = val["instance_count"]
    }

  }

}


module "k8s_controle_node" {
  source = "github.com/MOUAK-Ayoub/terraform-modules.git/ec2-module"

  vpc-id    = module.windows_admin_vpc.vpc_id
  subnet-id = module.windows_admin_vpc.subnet_ids
  sg-rules  = var.windows-sg-rules
  key-name  = aws_key_pair.key.key_name
  instances = local.master_instances_with_user_data
  ami_map   = var.ami_map


  depends_on = [module.windows_admin_vpc, aws_key_pair.key]

}


module "k8s_slaves_nodes" {
  source = "github.com/MOUAK-Ayoub/terraform-modules.git/ec2-module"

  vpc-id    = module.windows_admin_vpc.vpc_id
  subnet-id = module.windows_admin_vpc.subnet_ids
  sg-rules  = var.windows-sg-rules
  key-name  = aws_key_pair.key.key_name
  instances = local.slave_instances_with_user_data
  ami_map   = var.ami_map


  depends_on = [module.windows_admin_vpc, module.k8s_controle_node, aws_key_pair.key]

}


resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "key" {
  content  = tls_private_key.key.private_key_pem
  filename = "files/win_key.pem"
}

resource "aws_key_pair" "key" {
  key_name   = "win-key"
  public_key = tls_private_key.key.public_key_openssh
}
