// THIS FILE IS FOR SHOWING OUTPUTS AFTER APPLY IS A SUCCESS!!

// the name of the output resource can be of our choice
# output "instance_public_ips" {
#   value = aws_instance.myec2[*].public_ip // aws_instance.myec2[*].public_ip gives you a list of all EC2 public IPs.
# }

output "security_group_id" {
  value = module.myservers["web1"].security_group_id
}


# output "elastic_ips" {
#   // This is called splat syntax
#   value = aws_eip.my_eip[*].public_ip // aws_eip.my_eip[*].public_ip gives you a list of all Elastic IPs.
# }

# output "ssh_allowed_ips" {
#   value = var.ssh_allowed_ips
# }


// aws_instance.myec2["web1"].public_ip
output "instance_ips" {
  value = {
    for name, mod in module.myservers : name => mod.public_ip
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_id" {
  value = module.vpc.subnet_id
}