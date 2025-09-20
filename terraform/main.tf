provider "aws" {
  region = var.region
}

# Pick a recent Ubuntu 22.04 AMI (Canonical)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "ecom-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "ecom-public-subnet" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "ecom-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "ecom-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "sg" {
  name        = "ecommerce-sg"
  description = "Allow HTTP and internal service communication"
  vpc_id      = aws_vpc.main.id

  # frontend public
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  # Allow SSH from your IP (change variable)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Internal service communication: allow same SG (self) on ports 3001-3004
  ingress {
    description = "internal services"
    from_port   = 3001
    to_port     = 3004
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ecommerce-sg" }
}

# Local image names
locals {
  user_image     = "${var.dockerhub_user}/user-service:${var.image_tag}"
  products_image = "${var.dockerhub_user}/products-service:${var.image_tag}"
  orders_image   = "${var.dockerhub_user}/orders-service:${var.image_tag}"
  cart_image     = "${var.dockerhub_user}/cart-service:${var.image_tag}"
  frontend_image = "${var.dockerhub_user}/frontend-service:${var.image_tag}"
}

# EC2 instance (single)
resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user-data.tpl", {
    user_image     = local.user_image,
    products_image = local.products_image,
    orders_image   = local.orders_image,
    cart_image     = local.cart_image,
    frontend_image = local.frontend_image
  })

  tags = {
    Name = "ecommerce-app"
  }
}
