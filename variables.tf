variable "public_key_path" {
  description = "aws key"
  default     = "~/.ssh/aws.pub"
}

variable "key_name" {
  description = "aws ssh key"
  default     = "aws_key"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

# AMI
variable "aws_amis" {
  default = {
    us-west-2 = "ami-6df1e514"
  }
}

variable "eip" {
  default = {
    admin = "eipalloc-27e2011a"               #35.160.30.102
  }
}
