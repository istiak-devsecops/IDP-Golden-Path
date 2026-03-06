# aws vpc
resource "aws_vpc" "hub_vpc" {
  cidr_block = var.cidr_block  # User input from the variables
  enable_dns_hostnames = true  # tells to assign a public and private dns name to any ec2 instance launch in this VPC
  enable_dns_support = true     # enables route 53 dns support

  tags = {
    Name = "${var.vpc_name}"   # user input from the variables
  }
}

# aws subnet
resource "aws_subnet" "public_hub_subnet" {
  for_each = toset(var.public_subnets)  # set of multiple public subnet

  vpc_id     = aws_vpc.hub_vpc.id       # attatch to the vpc
  cidr_block = each.value               # for each subnet a cidr block

  # Ensures HA for the public subnet
  availability_zone = data.aws_availability_zones.available.names[
    index(var.public_subnets, each.value) % length(data.aws_availability_zones.available.names)
  ]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-${each.value}"
  }
}

resource "aws_subnet" "private_hub_subnet" {
  for_each = toset(var.private_subnets) # set of multiple private subnet

  vpc_id     = aws_vpc.hub_vpc.id       # attatch to the vpc
  cidr_block = each.value               # for each subnet a cidr block
  # Ensure HA zone for the private subnet
  availability_zone = data.aws_availability_zones.available.names[
    index(var.public_subnets, each.value) % length(data.aws_availability_zones.available.names)
  ]

  tags = {
    Name = "${var.vpc_name}-private-${each.value}"
  }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.hub_vpc.id  # internet gateway attatch to the vpc id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Elastic IP
resource "aws_eip" "hub_eip" {
  domain   = "vpc"  # defines if this EIP will be used for vpc
}


# nat gateway
resource "aws_nat_gateway" "hub_nat" {
  allocation_id = aws_eip.hub_eip.id    
  # Logic: Pick the specific public subnet mapped to your first CIDR
  # This ensures the NAT Gateway stays in the 'A' zone consistently.
  subnet_id     = aws_subnet.public_hub_subnet[var.public_subnets[0]].id
  

  depends_on = [aws_internet_gateway.igw]     # Dependency mapping for igw
  tags = {
    Name = "${var.vpc_name}-hub-Nat"
  }
}


# Route table for public vpc
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.hub_vpc.id       

  route {
    cidr_block = "0.0.0.0/0"    # Traffic destination to the internet
    gateway_id = aws_internet_gateway.igw.id  # for public route table use internet gateway
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# Attatch public route table and public subnet to configure public route table association
resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public_hub_subnet   # configure for each subnet
  subnet_id      = each.value.id            # get the subnet id for each subnet
  route_table_id = aws_route_table.public_rt.id  # attatch the public route table id
}

# route table for private vpc
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.hub_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.hub_nat.id # for private vpc use nat gateway
  }

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private_hub_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}





