provider "aws" {
	region = ""
}

resource "aws_security_group" "for-webserver" {
   name = "WebServer SG"
   description = ""

   ingress {
    from_port = 80
    to_port   = 80
    protocol  = "-1"
    cidr_blocks = ""
   } 

   egress {
    from_port = 0
    to_port   = 0 
    protocol  = "-1"
    cidr_blocks = [""]
   }

  tags = {
   Name = ""
   Owner = "Maxim Yankowsky"
  }
}