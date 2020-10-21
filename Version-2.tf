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

resource "aws-subnet" "subnet1" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr__block             = "10.1.3.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "sub-1a"
  }
}

resource "aws-subnet" "subnet2" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr__block             = "10.2.3.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "sub-2b"
  }
}

resource "aws-subnet" "subnet3" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr__block             = "10.3.3.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "sub-3c"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "int-gw-1"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "maxim-public"
  }
}

resource "aws_route_table_association" "subnet_association-1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "subnet_association-2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "subnet_association-3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_eip" "ftip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.gw"]

}
