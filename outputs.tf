// THIS FILE IS FOR SHOWING OUTPUTS AFTER APPLY IS A SUCCESS!!

// the name of the output resource can be of our choice
output "instance_public_ip" {
  value = aws_instance.myec2.public_ip
}


output "security_group_id" {
  value = aws_security_group.my_sg.id
}

output "elastic_ip" {
  value = aws_eip.my_eip.public_ip
}


# output "ssh_allowed_ips" {
#   value = var.ssh_allowed_ips
# }