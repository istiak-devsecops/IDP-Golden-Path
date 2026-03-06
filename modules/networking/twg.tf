resource "aws_route" "private_tgw_route" {  # requires in both hub and spoke
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "10.1.0.0/16" # Your Spoke VPC range
  # destination_cidr_blok for spoke will be "0.0.0.0/0" to send everything to the hub
  transit_gateway_id     = aws_ec2_transit_gateway.hub_transit.id # Your TGW ID
  # transit gateway id for spoke data.terraform_remote_state.hub.outputs.tgw_id
}


# Transite gateway for hub
resource "aws_ec2_transit_gateway" "hub_transit" {
  description = "hub router"
  default_route_table_association = "disable" # Essential for custom logic
  default_route_table_propagation = "disable" # Essential for custom logic
}

# Hub and spoke share the same tgw route table so don't need it in the spoke requires only in hub
resource "aws_ec2_transit_gateway_route_table" "hub_transit_rt" { # requires only in hub 
  transit_gateway_id = aws_ec2_transit_gateway.hub_transit.id
}


resource "aws_ec2_transit_gateway_vpc_attachment" "hub_transit_atta" { # requires in both hub and spoke
  subnet_ids         = [for s in aws_subnet.private_hub_subnet : s.id]      # 
  transit_gateway_id = aws_ec2_transit_gateway.hub_transit.id
  vpc_id             = aws_vpc.hub_vpc.id
}

resource "aws_ec2_transit_gateway_route_table_association" "hub_transit_asso" { # requires in both hub and spoke
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub_transit_atta.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub_transit_rt.id  # in spoke tgw use hub transit round table instead of spoke
}


resource "aws_ec2_transit_gateway_route_table_propagation" "hub_transit_propagation" { # requires in both hub and spoke
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub_transit_atta.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub_transit_rt.id   # in spoke tgw use hub transit round table instead of spoke
}

