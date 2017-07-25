resource "aws_db_subnet_group" "krdb_group" {
  name       = "krdb_group"
  subnet_ids = ["${aws_subnet.default.id}","${aws_subnet.b.id}"]

  tags {
    Name = "DB subnet group"
  }
}

resource "aws_db_instance" "krdb1" {
  allocated_storage    = 5
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.6.35"
  instance_class       = "db.t2.micro"
  name                 = "krdb1"
  username             = "kradmin"
  password             = "blahblah"
  db_subnet_group_name = "krdb_group"
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
}

# DNS record
resource "aws_route53_record" "krdb1" {
   zone_id = "${aws_route53_zone.dev.zone_id}"
   name = "krdb1.dev.krolm.com"
   type = "CNAME"
   ttl = "300"
   records = ["${aws_db_instance.krdb1.address}"]
}
