resource "aws_vpc" "cyber94_calc2_cmetcalfe_vpc_tf" {
  cidr_block = "10.4.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "cyber94_calc2_cmetcalfe_vpc"
  }
}

resource "aws_internet_gateway" "cyber94_calc2_cmetcalfe_ig_tf" {
  vpc_id = aws_vpc.cyber94_calc2_cmetcalfe_vpc_tf.id

  tags = {
    Name = "cyber94_calc2_cmetcalfe_vpc_tf.id"
  }
}

resource "aws_route_table" "cyber94_calc2_cmetcalfe_internet_rt_tf" {
  vpc_id = aws_vpc.cyber94_calc2_cmetcalfe_vpc_tf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cyber94_calc2_cmetcalfe_ig_tf.id
  }
}

resource "aws_route53_zone" "cyber94_calc2_cmetcalfe_vpc_dns_tf" {
  name = "cyber-4.sparta"

  vpc {
    vpc_id = aws_vpc.cyber94_calc2_cmetcalfe_vpc_tf.id
  }

}
