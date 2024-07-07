

provider "aws" {
  region = "ap-south-1"  # Change to your preferred region
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my_key" {
  key_name   = "MyKeyPair"
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_security_group" "my_security_group" {
  name        = "my_security_group"
  description = "Allow inbound traffic on ports 443, 80, and 22"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "master" {
  ami           = "ami-0ad21ae1d0696ad58"  # Change to your preferred AMI ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.my_security_group.name]

  tags = {
    Name = "master"
  }
}

resource "aws_instance" "ansible" {
  ami           = "ami-0ad21ae1d0696ad58"  # Change to your preferred AMI ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.my_security_group.name]

  tags = {
    Name = "ansible"
  }
}

output "private_key_pem" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}
