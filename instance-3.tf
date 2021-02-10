provider "aws" {
	access_ket = ""
	secret_key = ""
	region     = ""
}

resource "aws_instance" "Ubuntu" {
	count         = 3
	ami           = "ami-090f10efc254eaf55"
	instance_type = "t2.micro"
	vpc_security_group_ids = [""]
	user_data = <<EOF

EOF

	tags = {
	  Name = ""
	  Owner = "Maxim Yankowsky"
	  Project = "" 
	}
}