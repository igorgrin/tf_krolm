### WEB instance
resource "aws_instance" "web" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ec2-user"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.ping.id}","${aws_security_group.ssh.id}","${aws_security_group.http.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.default.id}"

  # We run a remote provisioner on the instance after creating it.
  # Fix the hostname
  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo hostname ${aws_instance.web.tags.Name} && echo ${aws_instance.web.tags.Name} |sudo tee /etc/hostname",
      "sudo echo 127.0.0.1 ${aws_instance.web.tags.Name}.krolm.com ${aws_instance.web.tags.Name} |sudo tee -a /etc/hosts",
      "sudo echo ${aws_instance.web.private_ip} ${aws_instance.web.tags.Name}.krolm.com ${aws_instance.web.tags.Name} |sudo tee -a /etc/hosts"
    ]
  }

  # Name tag
  tags {
    Name        = "web"
  }
}

# DNS record
resource "aws_route53_record" "web" {
   zone_id = "${aws_route53_zone.dev.zone_id}"
   name = "web.dev.krolm.com"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.web.private_ip}"]
}
