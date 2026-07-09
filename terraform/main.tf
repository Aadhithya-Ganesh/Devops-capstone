provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "k8s_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "k8s-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.k8s_vpc.id
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = "public-subnet"
    }
}

resource "aws_internet_gateway" "k8s_internet_gateway" {
    vpc_id = aws_vpc.k8s_vpc.id

    tags = {
        Name = "k8s_internet_gateway"
    }
}

resource "aws_route_table" "k8s_route_table" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_internet_gateway.id
  }

  tags = {
    Name = "k8s_route_table"
  }
}

resource "aws_route_table_association" "k8s_route_table_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.k8s_route_table.id
}

resource "aws_security_group" "k8s_sg" {
  name        = "allow ssh and all outbound"
  description = "Allow ssh inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.k8s_vpc.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.k8s_sg.id
}

resource "aws_security_group_rule" "allow_http_inbound" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.k8s_sg.id
}

resource "aws_security_group_rule" "allow_all_outbound_public" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_sg.id
}

resource "aws_security_group_rule" "allow_kubernetes_node_port" {
    type = "ingress"
    from_port = 30000
    to_port = 32767
    protocol = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_sg.id
}

resource "aws_security_group_rule" "allow_kubernetes_api_server" {
    type = "ingress"
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_sg.id
}

resource "aws_security_group_rule" "allow_kubernetes_node_communcation" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.k8s_sg.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "k8s_public_instance1" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  key_name                    = "k8s-key-pair"
  
  tags = {
    Name = "my-k8s_public_instance1"
    Role = "control-plane"
  }
}

resource "aws_instance" "k8s_public_instance2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  key_name                    = "k8s-key-pair"
  
  tags = {
    Name = "k8s_public_instance2"
    Role = "worker-node"
  }
}