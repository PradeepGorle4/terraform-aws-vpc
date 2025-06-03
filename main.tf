resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"
    enable_dns_hostnames = var.enable_dns_hostnames

    tags = merge(
        var.common_tags,
        var.vpc_tags,
        {
            Name = local.resource_name
        }
    )
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        var.common_tags,
        var.igw_tags,
        {
            Name = local.resource_name
        }
    )
}

resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs) # count = 2 basically
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = local.azs_names[count.index]
    map_public_ip_on_launch = true # Since we are creating public subnets, assigning public IP's to them, by defaut they aren't assigned

# We can give name as expense-dev-public-useast-1a
    tags = merge(
        var.common_tags,
        var.public_subnet_tags,
        {
            Name = "${local.resource_name}--Public-${local.azs_names[count.index]}"
        }
    )
}

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = local.azs_names[count.index]
    

# We can give name as expense-dev-private-useast-1a
    tags = merge(
        var.common_tags,
        var.private_subnet_tags,
        {
            Name = "${local.resource_name}--Private-${local.azs_names[count.index]}"
            kubernetes.io/role/internal-elb = "1"
        }
    )
}

resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.database_subnet_cidrs[count.index]
    availability_zone = local.azs_names[count.index]

# We can give name as expense-dev-private-useast-1a
    tags = merge(
        var.common_tags,
        var.database_subnet_tags,
        {
            Name = "${local.resource_name}--database-${local.azs_names[count.index]}"
        }
    )
}

resource "aws_eip" "nat" {
    domain = "vpc"
}

resource "aws_nat_gateway" "example" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public[0].id

    tags = merge(
        var.common_tags,
        var.nat_gateway_tags,
        {
            Name = "${local.resource_name}-${local.azs_names[0]}"
        }
    )

    # To ensure proper ordering, it is recommended to add an explicit dependency
    # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
    
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        var.common_tags,
        var.public_route_table_tags,
        {
            Name = "${local.resource_name}--public"
        }
    )
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        var.common_tags,
        var.private_route_table_tags,
        {
            Name = "${local.resource_name}--private"
        }
    )
}

resource "aws_route_table" "database" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        var.common_tags,
        var.database_route_table_tags,
        {
            Name = "${local.resource_name}--database"
        }
    )
}

resource "aws_route" "public" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id

}

resource "aws_route" "private" {
    route_table_id = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id

}

resource "aws_route" "database" {
    route_table_id = aws_route_table.database.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id
}

resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidrs) # since there are 2 public subnets, both of them should be associated
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
    count = length(var.private_subnet_cidrs) # since there are 2 private subnets, both of them should be associated
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
    count = length(var.database_subnet_cidrs) # since there are 2 database subnets, both of them should be associated
    subnet_id = aws_subnet.database[count.index].id
    route_table_id = aws_route_table.database.id
}