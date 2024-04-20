resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }
}


resource "aws_vpc_peering_connection" "main" {
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.main.id
  auto_accept = true
  tags = {
    Name = "${var.env}-vpc-to-default-vpc"
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-igw"
  }
}

#ed so totally we created
resource "aws_subnet" "frontend" {                    #subnet for frontend
  count = length(var.frontend_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.frontend_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env}-frontend-subnet-${count.index+1}"
  }
}


resource "aws_route_table" "frontend" {             #route table for frontnd
  count = length(var.frontend_subnets)              #count is for becuse there weere two subnets and ip address
  vpc_id = aws_vpc.main.id
  route {                                             #adding peer connection
    cidr_block = var.default_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }
  tags = {
    Name = "${var.env}-frontend-rt-${count.index+1}"
  }

}


resource "aws_subnet" "backend" {
  count = length(var.backend_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.backend_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env}-backend-subnet-${count.index+1}"
  }
}

resource "aws_route_table" "backend" {             #route table for backend
  count = length(var.backend_subnets)
  vpc_id = aws_vpc.main.id
  route {                                             #adding peer connection
    cidr_block = var.default_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }
  tags = {
    Name = "${var.env}-backend-rt-${count.index+1}"
  }

}

resource "aws_subnet" "db" {
  count = length(var.db_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.db_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env}-db-subnet-${count.index+1}"
  }
}

resource "aws_route_table" "db" {             #route table for db
  count = length(var.db_subnets)
  vpc_id = aws_vpc.main.id
  route {                                             #adding peer connection
    cidr_block = var.default_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }
  tags = {
    Name = "${var.env}-db-rt-${count.index+1}"
  }

}




resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env}-public-subnet-${count.index+1}"
  }
}

resource "aws_route_table" "public" {             #route table for public
  count = length(var.public_subnets)
  vpc_id = aws_vpc.main.id
  route {                                             #adding peer connection
    cidr_block = var.default_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }
  tags = {
    Name = "${var.env}-public-rt-${count.index+1}"
  }

}

resource "aws_route" "default-vpc" {
  route_table_id   = var.default_route_table_id
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  destination_cidr_block = var.vpc_cidr_block
}






