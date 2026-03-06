output "vpc_id" {
  value = aws_vpc.hub_vpc.id
}

output "transit_gateway_id" {
    value = aws_ec2_transit_gateway.hub_transit.id
}