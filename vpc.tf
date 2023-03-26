resource "aws_vpc" "ecs-vpc" {
  cidr_block       = var.vpccidr
  

  tags = {
    Name = "ECS-VPC"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ecs-vpc.id

  tags = {
    Name = "ECS-VPC"
  }
}

resource "aws_subnet" "publicsub1" {
  vpc_id     = aws_vpc.ecs-vpc.id
  cidr_block = var.publiccidr1
  map_public_ip_on_launch = true
availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "ECS-Publicsubnet1"
  }
}
resource "aws_subnet" "publicsub2" {
  vpc_id     = aws_vpc.ecs-vpc.id
  cidr_block = var.publiccidr2
  map_public_ip_on_launch = true
availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "ECS-Publicsubnet2"
  }
}
resource "aws_subnet" "privatesub1" {
  vpc_id     = aws_vpc.ecs-vpc.id
  cidr_block = var.privatecidr1
availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "ECS-Privatesubnet1"
  }
}

resource "aws_subnet" "privatesub2" {
  vpc_id     = aws_vpc.ecs-vpc.id
  cidr_block = var.privatecidr2
availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "ECS-Privatesubnet2"
  }
}

resource "aws_eip" "eip1" {
  vpc = true
  depends_on                = [aws_internet_gateway.gw]
}
resource "aws_eip" "eip2" {
  vpc = true
  depends_on                = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.publicsub1.id

  tags = {
    Name = "gw NAT public1"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.publicsub2.id

  tags = {
    Name = "gw NAT public2"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.ecs-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "ecs-public-route"
  }
}

resource "aws_route_table_association" "association_public1" {
  subnet_id      = aws_subnet.publicsub1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "association_public2" {
  subnet_id      = aws_subnet.publicsub2.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table" "route_table2" {
  vpc_id = aws_vpc.ecs-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat1.id
  }


  tags = {
    Name = "ecs-public-route"
  }
}

resource "aws_route_table_association" "association_private1" {
  subnet_id      = aws_subnet.privatesub1.id
  route_table_id = aws_route_table.route_table2.id
}

resource "aws_route_table" "route_table3" {
  vpc_id = aws_vpc.ecs-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat2.id
  }


  tags = {
    Name = "ecs-public-route"
  }
}
resource "aws_route_table_association" "association_private2" {
  subnet_id      = aws_subnet.privatesub2.id
  route_table_id = aws_route_table.route_table3.id
}