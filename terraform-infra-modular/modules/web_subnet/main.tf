resource "aws_subnet" "cyber94_calc2_cmetcalfe_subnet_web_tf" {
  vpc_id =  var.var_aws_vpc_id
  cidr_block = "10.4.1.0/24"

  tags = {
    Name = "cyber94_calc2_cmetcalfe_subnet_web_tf"
  }
}

resource "aws_route_table_association" "cyber94_calc2_cmetcalfe_subnet_web_assoc_tf" {
    subnet_id = aws_subnet.cyber94_calc2_cmetcalfe_subnet_web_tf.id
    route_table_id = var.var_internet_route_table
}
