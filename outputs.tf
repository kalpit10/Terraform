// THIS FILE IS FOR SHOWING OUTPUTS AFTER APPLY IS A SUCCESS!!

output "instance_public_ip" {
  value = aws_instance.myec2.public_ip
}