# EC2 Security Group
resource "aws_security_group" "ec2" {
  name        = "sg_ec2"
  description = "sg_ec2"
  vpc_id      = aws_vpc.vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_ec2"
  }
}

resource "aws_security_group_rule" "http" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  source_security_group_id = aws_security_group.elb.id

  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.ec2.id
}

# EFS Security Group
resource "aws_security_group" "efs" {
  name        = "sg_efs"
  description = "sg_efs"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    security_groups = [aws_security_group.ec2.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_efs"
  }
}

# ELB Security Group
resource "aws_security_group" "elb" {
  name        = "sg_alb"
  description = "sg_alb"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "sg_alb"
  }
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name        = "sg_rds"
  description = "sg_rds"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    security_groups = [aws_security_group.ec2.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_rds"
  }
}