# EFS
resource "aws_efs_file_system" "efs" {
  encrypted = "true"
  tags = {
    Name = "mount_point_efs"
  }
}

# EFS Mount Target 1a
resource "aws_efs_mount_target" "efs_1a" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private_subnet_1a.id
  security_groups = [aws_security_group.efs.id]
}

# EFS Mount Target 1b
resource "aws_efs_mount_target" "efs_1b" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private_subnet_1b.id
  security_groups = [aws_security_group.efs.id]
}