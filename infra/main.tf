# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"  # Choose your preferred region
}

# Define a security group for the instance
resource "aws_security_group" "springboot_sg" {
  name        = "springboot_sg"
  description = "Allow inbound traffic for Spring Boot application"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # New rule for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # New rule for HTTPS
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

# Define the EC2 instance
resource "aws_instance" "springboot_instance" {
  ami           = "ami-01b799c439fd5516a"  # Amazon Linux 2 AMI (HVM)
  instance_type = "t2.micro"              # Cheapest instance type
  key_name      = aws_key_pair.deployer.key_name

  security_groups = [aws_security_group.springboot_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              # Install Java 19 using Corretto (if available) or another source
              sudo rpm --import https://yum.corretto.aws/corretto.key
              sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
              sudo yum install -y java-19-amazon-corretto-devel

              # Alternatively, install OpenJDK 19 from other sources if Corretto 19 isn't available
              # sudo dnf install -y java-19-openjdk-devel

              # Download and run Spring Boot application
              sudo curl -o /opt/springboot-app.jar <URL_TO_YOUR_SPRINGBOOT_JAR>
              sudo nohup java -jar /opt/springboot-app.jar > /opt/springboot-app.log 2>&1 &
              EOF

  tags = {
    Name = "SpringBootEndpoint"
  }
}

resource "aws_elasticache_cluster" "example_redis" {
  cluster_id           = "example-redis-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.x"  # Choose the Redis version you need
  port                 = 6379

  subnet_group_name    = aws_elasticache_subnet_group.agencydb.name
  security_group_ids   = [aws_security_group.redis_security_group.id]
}


resource "aws_elasticache_subnet_group" "agencydb" {
  name       = "agency-subnet-group"
  subnet_ids = ["subnet-01398bd670ef3cc2b"]  # Replace with your actual subnet IDs
}

resource "aws_security_group" "redis_security_group" {
  name        = "redis_security_group"
  description = "Allow Redis traffic"

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Modify this to restrict access as necessary
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id      = "vpc-006c8c6d018a40674"  # Replace with your actual VPC ID
}

output "redis_address" {
  description = "The connection endpoint for the Redis instance"
  value       = aws_elasticache_cluster.example_redis.cache_nodes.0.address
}

output "redis_port" {
  description = "The connection port for the Redis instance"
  value       = aws_elasticache_cluster.example_redis.port
}

# Define a key pair for SSH access
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Output the public IP of the instance
output "instance_public_ip" {
  description = "Public IP of the Spring Boot EC2 instance"
  value       = aws_instance.springboot_instance.public_ip
}