output "instance_id" {
  value = aws_instance.myec2.id
}


output "security_group_id" {
  value = aws_security_group.my_sg.id
}

output "public_ip" {
  value = aws_instance.myec2.public_ip
}
