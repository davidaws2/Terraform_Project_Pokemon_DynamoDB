# Define the provider
provider "aws" {
  region = "us-west-2"
}

# Create VPC
resource "aws_vpc" "pokemon_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "pokemon-vpc"
  }
}

# Create Public Subnet
resource "aws_subnet" "pokemon_subnet" {
  vpc_id                  = aws_vpc.pokemon_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "pokemon-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "pokemon_igw" {
  vpc_id = aws_vpc.pokemon_vpc.id
  tags = {
    Name = "pokemon-igw"
  }
}

# Create Route Table
resource "aws_route_table" "pokemon_route_table" {
  vpc_id = aws_vpc.pokemon_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pokemon_igw.id
  }

  tags = {
    Name = "pokemon-route-table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "pokemon_route_assoc" {
  subnet_id      = aws_subnet.pokemon_subnet.id
  route_table_id = aws_route_table.pokemon_route_table.id
}

# Create Security Group
resource "aws_security_group" "pokemon_sg" {
  name        = "pokemon-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.pokemon_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pokemon-sg"
  }
}

# Create a new key pair
resource "tls_private_key" "pokemon_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "pokemon_key_pair" {
  key_name   = "pokemon_key_pair"
  public_key = tls_private_key.pokemon_key.public_key_openssh
}

# Save private key locally
resource "local_file" "pokemon_private_key" {
  content  = tls_private_key.pokemon_key.private_key_pem
  filename = "pokemon_key.pem"
}

# Create EC2 Instance
resource "aws_instance" "pokemon_server" {
  ami                    = "ami-0d081196e3df05f4d"  # Amazon Linux 2 AMI in us-west-2
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.pokemon_key_pair.key_name
  subnet_id              = aws_subnet.pokemon_subnet.id
  vpc_security_group_ids = [aws_security_group.pokemon_sg.id]
  tags = {
    Name = "pokiapi"
  }
   #!/bin/bash
                yum update -y
                yum install -y python3 python3-pip git
                pip3 install boto3 requests
                git clone https://github.com/davidaws2/Terraform_Project_Pokemon_DynamoDB /home/ec2-user/pokemon-collector
                chown -R ec2-user:ec2-user /home/ec2-user/pokemon-collector
                chmod 400 pokemon_key.pem
                echo "python3 /home/ec2-user/pokemon-collector/pokemon_collector.py"
}

# Create DynamoDB Table
resource "aws_dynamodb_table" "pokemon_table" {
  name           = "PokemonCollection"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "name"

  attribute {
    name = "name"
    type = "S"
  }

  tags = {
    Name = "pokemon-dynamodb-table"
  }
}

# Output EC2 Instance Public IP
output "server_public_ip" {
  value = aws_instance.pokemon_server.public_ip
}

# Output instructions for using the private key
output "key_instructions" {
  value = "A new private key has been generated and saved as 'pokemon_key.pem'.
           verify that is a chmod 400 'pokemon_key.pem' - permission read only by the user.
           if not set the correct permissions chmod 400 'pokemon_key.pem'.
  ssh = you can use - 'ssh -i pokemon_key.pem ec2-user@${aws_instance.pokemon_server.public_ip}' to connect to the instance."
}
