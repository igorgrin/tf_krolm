# admin instance
resource "aws_instance" "admin" {
  connection {
    user = "ec2-user"
  }

  instance_type = "t2.micro"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.ping.id}","${aws_security_group.ssh.id}"]
  subnet_id = "${aws_subnet.default.id}"

  # Fix the hostname
  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo hostname ${aws_instance.admin.tags.Name} && echo ${aws_instance.admin.tags.Name} |sudo tee /etc/hostname",
      "sudo echo 127.0.0.1 ${aws_instance.admin.tags.Name}.krolm.com ${aws_instance.admin.tags.Name} |sudo tee -a /etc/hosts",
      "sudo echo ${aws_instance.admin.private_ip} ${aws_instance.admin.tags.Name}.krolm.com ${aws_instance.admin.tags.Name} |sudo tee -a /etc/hosts"
    ]
  }

  tags {
    Name        = "admin"
  }
}

resource "aws_eip_association" "admin_ip" {
  instance_id = "${aws_instance.admin.id}"
  allocation_id = "${var.eip["admin"]}"
}

resource "aws_route53_record" "admin" {
   zone_id = "${aws_route53_zone.dev.zone_id}"
   name = "admin.dev.krolm.com"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.admin.private_ip}"]
}
