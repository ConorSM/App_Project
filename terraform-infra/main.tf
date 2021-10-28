provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "cyber94-cmetcalfe2-bucket"
    key = "tfstate/test2/terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = "cyber94_calc_cmetcalfe_dynamodb_table_lock"
    encrypt = true
  }
}

# @component CalcApp (#app)
# @component CalcApp:VPC (#vpc)

# @connects #app to #vpc with HTTP,SSH
# @connects #vpc to #app with HTTP, SSH

resource "aws_vpc" "cyber94_calc_cmetcalfe_vpc_tf" {
  cidr_block = "10.104.0.0/16"

  tags = {
    Name = "cyber94_calc_cmetcalfe_vpc"
  }
}

# @component CalcApp:VPC:ig (#ig)

# @connects #vpc to #ig with HTTP
# @connects #ig to #vpc with HTTP
resource "aws_internet_gateway" "cyber94_calc_cmetcalfe_ig_tf" {
  vpc_id = aws_vpc.cyber94_calc_cmetcalfe_vpc_tf.id

  tags = {
    Name = "cyber94_calc_cmetcalfe_ig"
  }
}

resource "aws_route_table" "cyber94_calc_cmetcalfe_rt_tf" {
  vpc_id = aws_vpc.cyber94_calc_cmetcalfe_vpc_tf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cyber94_calc_cmetcalfe_ig_tf.id
  }

  tags = {
    Name = "cyber94_calc_cmetcalfe_rt"
  }
}

# @component CalcApp:VPC:Subnet (#subnet)
# @connects #vpc to #subnet with Network

resource "aws_subnet" "cyber94_calc_cmetcalfe_subnet_public_tf" {
  vpc_id = aws_vpc.cyber94_calc_cmetcalfe_vpc_tf.id
  cidr_block = "10.104.1.0/24"

  tags = {
    Name = "cyber94_calc_cmetcalfe_subnet_public"
  }
}

resource "aws_route_table_association" "cyber94_calc_cmetcalfe_rt_assoc_tf" {
  subnet_id = aws_subnet.cyber94_calc_cmetcalfe_subnet_public_tf.id
  route_table_id = aws_route_table.cyber94_calc_cmetcalfe_rt_tf.id
}

resource "aws_network_acl" "cyber94_calc_cmetcalfe_nacl_public_tf" {
  vpc_id = aws_vpc.cyber94_calc_cmetcalfe_vpc_tf.id

  ingress {
    protocol = "tcp"
    rule_no = 100
    from_port = 22
    to_port = 22
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }
  ingress {
    protocol = "tcp"
    rule_no = 1000
    from_port = 1024
    to_port = 65535
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  egress {
    protocol = "tcp"
    rule_no = 100
    from_port = 80
    to_port = 80
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  egress {
    protocol = "tcp"
    rule_no = 200
    from_port = 443
    to_port = 443
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  egress {
    protocol = "tcp"
    rule_no = 1000
    from_port = 1024
    to_port = 65535
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  subnet_ids = [aws_subnet.cyber94_calc_cmetcalfe_subnet_public_tf.id]

  tags = {
    Name = "cyber94_cmetcalfe_nacl_public"
  }
}

resource "aws_security_group" "cyber94_calc_cmetcalfe_sg_server_public_tf" {
  name = "cyber94_calc_cmetcalfe_sg_server_public"

  vpc_id = aws_vpc.cyber94_calc_cmetcalfe_vpc_tf.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.104.2.0/24"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cyber94_calc_cmetcalfe_sg_server_public"
  }
}

<<<<<<< HEAD

=======
# @component CalcApp:Web:Server (#web_server)

# @connects #subnet to #web_server with Network
# @connects #webserver to #subnet with Network

# @threat Flooding (#flooding)
# @exposes #web_server to Denial of Service with #flooding

# @threat attacker accesses #web_server via SSH (#sshconnect)
# @exposes server to attacker with #sshconnect
resource "aws_instance" "cyber94_calc_cmetcalfe_server_public" {
>>>>>>> 129f42520dc7d428d61397518046897bc096aac6
  ami = "ami-0943382e114f188e8"
  instance_type = "t2.micro"
  key_name = "cyber94-cmetcalfe"
  associate_public_ip_address = true
  subnet_id = aws_subnet.cyber94_calc_cmetcalfe_subnet_public_tf.id

  vpc_security_group_ids = [aws_security_group.cyber94_calc_cmetcalfe_sg_server_public_tf.id]
  count = 1

  tags = {
    Name = "cyber94_calc_cmetcalfe_server_public"
  }

   # Just to make sure that terraform will not continue to local-exec before the server is up
  connection {
   type = "ssh"
   user = "ubuntu"
   host = self.public_ip
   private_key = file("/home/kali/.ssh/cyber94-cmetcalfe.pem")
   }

 provisioner "remote-exec" {
   inline = [
     "pwd"
     ]
   }

 lifecycle {
  create_before_destroy = true
  }

 provisioner "local-exec" {
   working_dir = "../ansible/"
   command = "ansible-playbook -i ${self.public_ip}, -u ubuntu provisioner.yml"
  }

}

  #
  # connection {
  #   type = "ssh"
  #   user = "ubuntu"
  #   host = self.public_ip
  #   private_key = file("/home/kali/.ssh/cyber94-cmetcalfe.pem")
  # }
  #
  # provisioner "file" {
  #   source = "../init-scripts/docker-install.sh"
  #   destination = "/home/ubuntu/docker-install.sh"
  # }
  #
  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod 777 /home/ubuntu/docker-install.sh",
  #     "/home/ubuntu/docker-install.sh"
  #   ]
  # }

# @component CalcApp:VPC:Bastion (#bastion)
# @connects #vpc to #bastion with Network
resource "aws_subnet" "cyber94_calc_cmetcalfe_subnet_bastion_tf" {
  vpc_id = aws_vpc.cyber94_calc_cmetcalfe_vpc_tf.id
  cidr_block = "10.104.3.0/24"

  tags = {
    Name = "cyber94_calc_cmetcalfe_subnet_bastion"
  }
}

resource "aws_route_table_association" "cyber94_calc_cmetcalfe_rt_assoc_bastion_tf" {
  subnet_id = aws_subnet.cyber94_calc_cmetcalfe_subnet_bastion_tf.id
  route_table_id = aws_route_table.cyber94_calc_cmetcalfe_rt_tf.id
}

resource "aws_network_acl" "cyber94_calc_cmetcalfe_nacl_bastion_tf" {
  vpc_id = aws_vpc.cyber94_calc_cmetcalfe_vpc_tf.id

  ingress {
    protocol = "tcp"
    rule_no = 100
    from_port = 22
    to_port = 22
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }
  ingress {
    protocol = "tcp"
    rule_no = 200
    from_port = 1024
    to_port = 65535
    cidr_block = "10.104.2.0/24"
    action = "allow"
  }

  egress {
    protocol = "tcp"
    rule_no = 100
    from_port = 22
    to_port = 22
    cidr_block = "10.104.2.0/24"
    action = "allow"
  }

  egress {
    protocol = "tcp"
    rule_no = 1000
    from_port = 1024
    to_port = 65535
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  subnet_ids = [aws_subnet.cyber94_calc_cmetcalfe_subnet_bastion_tf.id]

  tags = {
    Name = "cyber94_cmetcalfe_nacl_bastion"
  }
}

resource "aws_security_group" "cyber94_calc_cmetcalfe_sg_server_bastion_tf" {
  name = "cyber94_calc_cmetcalfe_sg_server_bastion"

  vpc_id = aws_vpc.cyber94_calc_cmetcalfe_vpc_tf.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.104.2.0/24"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cyber94_calc_cmetcalfe_sg_server_bastion"
  }
}

# @component CalcApp:VPC:Bastion:BastionServer (#bastion_server)
# @connects #bastion to #bastion_server with Network
resource "aws_instance" "cyber94_calc_cmetcalfe_server_bastion" {
  ami = "ami-0943382e114f188e8"
  instance_type = "t2.micro"
  key_name = "cyber94-cmetcalfe"
  associate_public_ip_address = true
  subnet_id = aws_subnet.cyber94_calc_cmetcalfe_subnet_bastion_tf.id

  vpc_security_group_ids = [aws_security_group.cyber94_calc_cmetcalfe_sg_server_public_tf.id]
  count = 1

  tags = {
    Name = "cyber94_calc_cmetcalfe_server_bastion"
  }
}
# @component CalcApp:VPC:DB (#db)
resource "aws_subnet" "cyber94_calc_cmetcalfe_subnet_db_tf" {
  vpc_id = aws_vpc.cyber94_calc_cmetcalfe_vpc_tf.id
  cidr_block = "10.104.2.0/24"

  tags = {
    Name = "cyber94_calc_cmetcalfe_subnet_db"
  }
}

resource "aws_route_table_association" "cyber94_calc_cmetcalfe_rt_assoc_db_tf" {
  subnet_id = aws_subnet.cyber94_calc_cmetcalfe_subnet_db_tf.id
  route_table_id = aws_route_table.cyber94_calc_cmetcalfe_rt_tf.id
}

resource "aws_network_acl" "cyber94_calc_cmetcalfe_nacl_db_tf" {
  vpc_id = aws_vpc.cyber94_calc_cmetcalfe_vpc_tf.id

  ingress {
    protocol = "tcp"
    rule_no = 100
    from_port = 22
    to_port = 22
    cidr_block = "10.104.3.0/24"
    action = "allow"
  }
  ingress {
    protocol = "tcp"
    rule_no = 200
    from_port = 3306
    to_port = 3306
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  egress {
    protocol = "tcp"
    rule_no = 100
    from_port = 1024
    to_port = 65535
    cidr_block = "10.104.1.0/24"
    action = "allow"
  }

  egress {
    protocol = "tcp"
    rule_no = 200
    from_port = 1024
    to_port = 65535
    cidr_block = "10.104.3.0/24"
    action = "allow"
  }

  egress {
    protocol = "tcp"
    rule_no = 1000
    from_port = 1024
    to_port = 65535
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  subnet_ids = [aws_subnet.cyber94_calc_cmetcalfe_subnet_db_tf.id]

  tags = {
    Name = "cyber94_cmetcalfe_nacl_app"
  }
}

resource "aws_security_group" "cyber94_calc_cmetcalfe_sg_server_db_tf" {
  name = "cyber94_calc_cmetcalfe_sg_server_db"

  vpc_id = aws_vpc.cyber94_calc_cmetcalfe_vpc_tf.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.104.3.0/24"]
  }

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.104.1.0/24"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cyber94_calc_cmetcalfe1_sg_server_db"
  }
}

# @component CalcAPP:VPC:DB:DBserver (#dbserver)
# @connects #db to #dbserver with MySQL

# @exposes #dbserver to Information Disclosure with #sqlinjection


resource "aws_instance" "cyber94_calc_cmetcalfe_server_db" {
  ami = "ami-0943382e114f188e8"
  instance_type = "t2.micro"
  key_name = "cyber94-cmetcalfe"
  associate_public_ip_address = true
  subnet_id = aws_subnet.cyber94_calc_cmetcalfe_subnet_db_tf.id

  vpc_security_group_ids = [aws_security_group.cyber94_calc_cmetcalfe_sg_server_db_tf.id]
  count = 1

  tags = {
    Name = "cyber94_calc_cmetcalfe_server_db"
  }
}
