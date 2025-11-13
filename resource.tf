# 1. Create a Security Group (Firewall)
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow HTTP traffic"

  # This is the rule you will test
  ingress {
    from_port   = var.server_http_port
    to_port     = var.server_http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Create your EC2 Instance (with two lines added)
resource "aws_instance" "example" {
  instance_type = "t2.micro"
  ami           = "ami-02b8269d5e85954ef" # Your specified AMI

  # --- THIS IS THE FIX ---
  # We must tell the instance which network to live in
  subnet_id = aws_subnet.main.id
  
  # We must tell the instance which firewall to use
  vpc_security_group_ids = [aws_security_group.allow_web_ssh.id]
  # -----------------------
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > index.html
              nohup httpd -f -p ${var.server_http_port} &
              EOF
  tags = {
    Name = "ExampleInstance"
  }
}
# 1. Create the VPC (your private network)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# 2. Create a Subnet (a section of your network)
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  
  # This makes it a "public" subnet
  map_public_ip_on_launch = true 

  # This is the fix for the "t2.micro not supported" error
  availability_zone = "ap-south-1a"

  tags = {
    Name = "main-public-subnet"
  }
}

# 3. Create an Internet Gateway (to connect to the internet)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# 4. Create a Route Table (exit signs for the internet)
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # "Anywhere on the internet"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main-public-rt"
  }
}

# 5. Associate the Subnet with the Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.rt.id
}
output "instance_public_ip" {
  description = "Public IP address of the web server."
  value       = aws_instance.example.public_ip
}