resource "aws_vpc" "coachmeplusvpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "coachmeplusvpc"
  }
}

resource "aws_subnet" "pub_subn" {
  vpc_id     = aws_vpc.coachmeplusvpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "pub_subn"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "pri_subn" {
  vpc_id     = aws_vpc.coachmeplusvpc.id
  cidr_block = "10.0.2.0/24"
   availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "pri_subn"
  }
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.coachmeplusvpc.id

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

  tags = {
    Name = "alb_sg"
  }
}

# Create a security group for EC2 instances
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.coachmeplusvpc.id

  tags = {
    Name = "instance_sg"
  }

  
dynamic "ingress" {
    for_each = var.ports ["inbound"]
     content {
       from_port = ingress.value
       to_port = ingress.value 
       protocol = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
     }
      
}

egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

}


resource "aws_instance" "femitestinstance" {
  count         = 5
  ami           = "ami-07fb7b1409c393c50" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pri_subn.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  tags = {
    Name = "femitestinstance_${count.index}"
  }

  # Adding a key pair to access the instances
  key_name = aws_key_pair.femikey.key_name
}

# Create a key pair
resource "aws_key_pair" "femikey" {
  key_name   = "femikey"
  public_key = file("~/.ssh/femikey.pub") 
}

# # Create a target group
# resource "aws_lb_target_group" "my_target_group" {
#   name        = "my-targets"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = aws_vpc.coachmeplusvpc.id
#   target_type = "instance"

#   health_check {
#     path                = "/"
#     protocol            = "HTTP"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }

#   tags = {
#     Name = "my_target_group"
#   }
# }


# resource "aws_lb_target_group_attachment" "my_targets" {
#   count            = 2
#   target_group_arn = aws_lb_target_group.my_target_group.arn
#   target_id        = element(aws_instance.ubuntutestinstance.*.id, count.index)
#   port             = 80
# }

# # Create an ALB
# resource "aws_lb" "my_alb" {
#   name               = "my-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb_sg.id]
#   subnets =            [for subnet in aws_subnet.pub_subn : aws_subnet.pub_subn.id]
  

#   tags = {
#     Name = "my_alb"
#   }
# }

# # Create a listener for ALB
# resource "aws_lb_listener" "my_listener" {
#   load_balancer_arn = aws_lb.my_alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.my_target_group.arn
    
#   }
# }