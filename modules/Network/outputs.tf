output "module_vpc_id" {
  value       = aws_vpc.main_vpc.id
}

output "module_public_sb" {
  value = aws_subnet.public_sb.*.id
}

output "module_private_sb" {
  value = aws_subnet.private_sb.*.id
}