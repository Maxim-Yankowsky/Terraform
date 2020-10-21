provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "eu-west-2"
}

resource "aws_vpc" "main" {
  cidr_block      = "10.0.3.0/24"
  instance_tenacy = "default"

  tags = {
    Name = "Server-Cloud-1"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id                  = "{aws_vpc.main.id}"
  cidr__block             = "10.1.3.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "sub-1a"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = "{aws_vpc.main.id}"
  cidr__block             = "10.2.3.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "sub-2b"
  }
}

resource "aws_subnet" "subnet3" {
  vpc_id                  = "{aws_vpc.main.id}"
  cidr__block             = "10.3.3.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "sub-3c"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "{aws_vpc.main.id}"

  tags = {
    Name = "int-gw-1"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = "{aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "{aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "maxim-public"
  }
}

resource "aws_route_table_association" "subnet_association1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "subnet_association2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "subnet_association3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_instance" "wordpress_server1" {
  ami                    = "ami-074b3d335a0e553be"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_secyrity_group.mywebserver.id]
  user_data              = <<EOF
#!/bin/bash
yum update -y
yum install -y docker
sudo service docker start
sudo docker run -d -p 80:80 tutum/wordpress
sudo curl http://localhost
EOF

  tags = {
    Name = "Wordpress Server 1"
  }
}

resource "aws_instance" "wordpress_server2" {
  ami                    = "ami-074b3d335a0e553be"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  user_data              = <<EOF
#!/bin/bash
yum update -y
yum install -y docker
sudo service docker start
sudo docker run -d -p 80:80 tutum/wordpress
sudo curl http://localhost
EOF

  tags = {
    Name = "Wordpress Server 2"
  }
}

resource "aws_security_group" "my_webserver" {
  name        = "WebServer SG"
  description = "My First SG"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "0.0.0.0/0"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "0.0.0.0/0"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "0.0.0.0/0"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "example1" {
  instance = "{aws_instance.wordpress_server1.id}"
}

resource "aws_eip" "example2" {
  instance = "{aws_instance.wordpress_server2.id}"
}

resource "aws_launch-configuration" "example" {
  image_id        = "ami-074b3d335a0e553be"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.my_webserver.id]

  lifecycle {
    create_befor_destroy = true
  }
}

resource "aws_autoscaling_group" "expert" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  target_group_arns = [aws_alb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-expert"
    propagate_at_launch = true
  }
}

resource "aws_lb" "example" {
  name = var.alb_name

  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
}
