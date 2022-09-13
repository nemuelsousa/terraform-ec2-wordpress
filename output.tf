output "elb_dns_name" {
  value = aws_lb.elb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}