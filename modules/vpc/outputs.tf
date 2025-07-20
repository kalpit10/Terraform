// These outputs will be used by the root module (main folder) as an input while alloting ids:

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_id" {
  value = aws_subnet.my_public_subnet.id
}
