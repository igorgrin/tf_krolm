resource "aws_route53_record" "mx" {
   zone_id = "${aws_route53_zone.main.zone_id}"
   name = "krolm.com"
   type = "MX"
   ttl = "300"
   records = [
     "1 aspmx.l.google.com.",
     "5 alt1.aspmx.l.google.com.",
     "5 alt2.aspmx.l.google.com.",
     "10 alt3.aspmx.l.google.com.",
     "10 alt4.aspmx.l.google.com.",
     "15 r2qbhixphq6c4ma42xwj3ulb2igzjjjok4p5mmehl3bo7jdmoa3q.mx-verification.google.com."]
}

resource "aws_route53_zone" "main" {
   name = "krolm.com"
}

resource "aws_route53_zone" "dev" {
  name = "dev.krolm.com"
  vpc_id                  = "${aws_vpc.default.id}"

  tags {
    Environment = "dev"
  }
}

resource "aws_route53_record" "dev-ns" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "dev.krolm.com"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.dev.name_servers.0}",
    "${aws_route53_zone.dev.name_servers.1}",
    "${aws_route53_zone.dev.name_servers.2}",
    "${aws_route53_zone.dev.name_servers.3}",
  ]
}

resource "aws_route53_record" "www_public" {
   zone_id = "${aws_route53_zone.main.zone_id}"
   name = "www.krolm.com"
   type = "A"
   alias {
     name = "${aws_elb.www.dns_name}"
     zone_id = "${aws_elb.www.zone_id}"
     evaluate_target_health = true
   }
}

resource "aws_route53_record" "apex" {
   zone_id = "${aws_route53_zone.main.zone_id}"
   name = "krolm.com"
   type = "A"
   alias {
     name = "${aws_elb.www.dns_name}"
     zone_id = "${aws_elb.www.zone_id}"
     evaluate_target_health = true
   }
}
