provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "demo_vpc" {
  cidr_block = "13.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "Demo-vpc"
  }
}

resource "aws_internet_gateway" "demo_ig" {
  vpc_id = aws_vpc.demo_vpc.id
  tags = {
    Name="Internet_gateway"
  }
}

resource "aws_route_table" "stage_pub_rt_table" {
  vpc_id = aws_vpc.demo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_ig.id
  }
}

resource "aws_route_table_association" "stage_pub_rt_table_ass" {
  subnet_id = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.stage_pub_rt_table.id
}

resource "aws_subnet" "subnet_1" {
  cidr_block = "13.0.0.0/24"
  vpc_id     = aws_vpc.demo_vpc.id
  availability_zone = "us-east-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "terra-subnet-1"
  }
}

resource "aws_security_group" "stage_security_group" {
  vpc_id = aws_vpc.demo_vpc.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port=0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "iam_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "Ec2_role_for_SES"
  }
}

locals {
  ami = "ami-04a81a99f5ec58529"
  s3FullAccessArn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  sesFullAccessArn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_poliy_attach" {
  role = aws_iam_role.iam_role.name
  policy_arn = local.s3FullAccessArn
}

resource "aws_iam_role_policy_attachment" "ses_policy_attach" {
  role = aws_iam_role.iam_role.name
  policy_arn = local.sesFullAccessArn
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "Ec2_role_for_SES"
  role = aws_iam_role.iam_role.name
}


resource "aws_instance" "Demo_Instance" {
  ami             = local.ami
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet_1.id
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.name
  security_groups = [aws_security_group.stage_security_group.id]
  tags = {
    Name = "demo_ec2_instance"
  }
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
}

resource "" "name" {
  
}