output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_public_1_id" {
  value = aws_subnet.public_1.id
}

output "subnet_public_2_id" {
  value = aws_subnet.public_2.id
}

output "ecs_instance_sg_id" {
  value = aws_security_group.ecs_sg.id
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}
