

variable "region" {
  default = "us-east-1"
}

variable "az-number" {
  type    = number
  default = 1
}

variable "vpc-cidr" {
  default = "10.0.0.0/16"
}

variable "newbits" {
  type        = number
  default     = 8
  description = "Look at the terraform function cidrsubnet, newbits is the second parameter"
}

variable "subnet-number" {
  type    = number
  default = 1
}

variable "ami_map" {
  type = map(string)
  default = {
    "linux" : "amzn2-ami-hvm*"
    "windows" : "Windows_Server-2019-English-Full-Base-*"
  }
}

variable "master_instances" {
  type = map(object({
    os_ami         = string,
    type           = string,
    user_data_path = optional(string),
    tag_name       = string,
    instance_count = number
  }))
  default = {
    "k8s_controller" = {
      os_ami         = "linux"
      type           = "t3.medium"
      user_data_path = "./user_data/k8s_master_script.sh"
      tag_name       = "k8s Controller"
      instance_count = 1
    }
  }
}

variable "slave_instances" {
  type = map(object({
    os_ami         = string,
    type           = string,
    user_data_path = optional(string),
    tag_name       = string,
    instance_count = number
  }))
  default = {
    "k8s_node" = {
      os_ami         = "linux"
      type           = "t3.small"
      user_data_path = "./user_data/k8s_slave_script.sh"
      tag_name       = "k8s node"
      instance_count = 2
    }
  }
}

variable "windows-sg-rules" {
  type = map(object({
    type                     = string,
    from_port                = number,
    to_port                  = number,
    protocol                 = string,
    source_security_group_id = optional(string),
    source_cidr_ip           = optional(list(string))
  }))
  default = {
    "allow_rdp" = {
      type           = "ingress"
      from_port      = 0
      to_port        = 0,
      protocol       = "-1",
      source_cidr_ip = ["0.0.0.0/0"]

      }, "allow_all_egress" = {
      type           = "egress"
      from_port      = 0
      to_port        = 0,
      protocol       = "-1",
      source_cidr_ip = ["0.0.0.0/0"]
    }
  }
}

variable "ansible_user" {
  type = object({
    user = string,
    pwd  = string,
  })
  default = {
    user = "ansible"
    pwd  = "Test2024!"
  }
}




