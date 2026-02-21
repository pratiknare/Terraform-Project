
#create eip for nat gateway az1 
resource "aws_eip" "eip_nat_1" {
  domain = "vpc"

  tags = {
    name = "eip_nat_1"
  }
}

#create eip for nat gateway az2
resource "aws_eip" "eip_nat_2" {
  domain = "vpc"

  tags = {
    name = "eip_nat_2"
  }
}

#create nat gateway in public subnet pub-sub-az1
resource "aws_nat_gateway" "nat_az1" {
  allocation_id = aws_eip.eip_nat_1.id
  subnet_id     = var.public_subnet_az1_id

  tags = {
    name = "nat_az1"
  }

  depends_on = [var.IGW]
}


#create nat gateway in public subnet pub-sub-az2
resource "aws_nat_gateway" "nat_az2" {
  allocation_id = aws_eip.eip_nat_2.id
  subnet_id     = var.public_subnet_az2_id

  tags = {
    name = "nat_az2"
  }

  depends_on = [var.IGW]
}


# create private route table nat_route_table_az1 and add route through nat_az1
resource "aws_route_table" "nat_route_table_az1" {
  vpc_id = var.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_az1.id
  }

  tags = {
    name = "nat_route_table_az1"
  }
}

# associate private subnet pri-_sub_app_az1 with private route table nat_route_table_az1
resource "aws_route_table_association" "pri_sub_app_az1_route_table" {
  subnet_id      = var.private_app_subnet_az1_id
  route_table_id = aws_route_table.nat_route_table_az1.id
}

# associate private subnet pri-_sub_data_az1 with private route table nat_route_table_az1
resource "aws_route_table_association" "pri_sub_data_az1_route_table" {
  subnet_id      = var.private_data_subnet_az1_id
  route_table_id = aws_route_table.nat_route_table_az1.id
}

# create private route table nat_route_table_az1 and add route through nat_az2
resource "aws_route_table" "nat_route_table_az2" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_az2.id
  }

  tags = {
    name = "nat_route_table_az2"
  }
}

# associate private subnet pri-_sub_app_az2 with private route table nat_route_table_az2
resource "aws_route_table_association" "pri_sub_app_az2_route_table" {
  subnet_id      = var.private_app_subnet_az2_id
  route_table_id = aws_route_table.nat_route_table_az2.id
}

# associate private subnet pri-_sub_app_az2 with private route table nat_route_table_az2
resource "aws_route_table_association" "pri_sub_data_az2_route_table" {
  subnet_id      = var.private_data_subnet_az2_id
  route_table_id = aws_route_table.nat_route_table_az2.id
}