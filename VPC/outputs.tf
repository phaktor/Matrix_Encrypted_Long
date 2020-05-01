output "VpcID" {
  value = aws_vpc.Matrix-VPC.id
}

output "PublicSubnet" {
  value = aws_subnet.PublicSubnet.id
}
