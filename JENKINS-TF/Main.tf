resource "aws_security_group" "Jenkins-sg" {
  name        = "Jenkins-Security-Group"
  description = "Open 22,443,80,8080,9000"

  # Define ingress rules using dynamic block
  dynamic "ingress" {
    for_each = [22, 80, 443, 8080, 9000, 3000]
    content {
      description      = "Allow port ${ingress.value}"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-sg"
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-0f5ee92e2d63afc18"  # Ubuntu 20.04 LTS
  instance_type          = "t3.micro"              # Free tier eligible t3.micro
  key_name               = "Mumbai"
  vpc_security_group_ids = [aws_security_group.Jenkins-sg.id]
  user_data              = templatefile("./install_jenkins.sh", {})

  tags = {
    Name = "Jenkins-sonar"
  }
  
  root_block_device {
    volume_size = 8  # Reduced to 8GB to stay within free tier limits
  }
}
