output "web_public_ip" {
  description = "Public IPv4 address of the web/application EC2 instance"
  value       = aws_instance.web.public_ip
}

output "db_private_ip" {
  description = "Private IPv4 address of the database EC2 instance"
  value       = aws_instance.db.private_ip
}

output "web_instance_id" {
  value = aws_instance.web.id
}

output "db_instance_id" {
  value = aws_instance.db.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}
