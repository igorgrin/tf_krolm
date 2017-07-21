variable "public_key_path" {
  description = "aws key"
  default     = "~/.ssh/aws.pub"
}

variable "key_name" {
  description = "aws ssh key"
  default     = "aws_ssh"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

# Ubuntu Trusty 14.04 LTS (x64)
variable "aws_amis" {
  default = {
    us-west-2 = "ami-9abea4fb"
  }
}
