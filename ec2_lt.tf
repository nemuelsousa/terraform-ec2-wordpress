# EC2 Launch Template
resource "aws_launch_template" "ec2_lt" {
  name          = "wordpress_lt"
  image_id      = "ami-05fa00d4c63e32376"
  instance_type = "t3.small"
  key_name      = aws_key_pair.key.id
  user_data     = base64encode(data.template_file.script.rendered)

  iam_instance_profile {
    name = "AmazonSSMRoleForInstancesQuickSetup"
  }

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = "8"
      volume_type           = "gp3"
      delete_on_termination = "true"
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "wordpress_app"
    }
  }

  tags = {
    Name = "wordpress_lt"
  }
}

# script user_data
data "template_file" "script" {
  template = file("script.tpl")
  vars = {
    efs_id = aws_efs_file_system.efs.id
  }
}

# Key Pair
resource "aws_key_pair" "key" {
  key_name   = "ec2_key"
  public_key = file("ec2_key.pub")
}