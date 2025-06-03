resource "aws_vpc_peering_connection" "peering" {
    count = var.is_peering_required ? 1 : 0
    vpc_id = aws_vpc.main.id # requestor vpc id
    peer_vpc_id = local.default_vpc_id # Accepter id
    auto_accept = true

    tags = merge(
        var.common_tags,
        var.vpc_peering_tags,
        {
            Name = "${local.resource_name}--default"
        }
    )
}

resource "aws_route" "public_subnet_peering" {
    count = var.is_peering_required ? 1 : 0 # when we use count, always use count.index
    route_table_id = aws_route_table.public.id
    destination_cidr_block = local.default_vpc_cidr
    gateway_id = aws_vpc_peering_connection.peering[count.index].id
}

resource "aws_route" "private_subnet_peering" {
    count = var.is_peering_required ? 1 : 0
    route_table_id = aws_route_table.private.id
    destination_cidr_block = local.default_vpc_cidr
    gateway_id = aws_vpc_peering_connection.peering[count.index].id
}

resource "aws_route" "database_subnet_peering" {
    count = var.is_peering_required ? 1 : 0
    route_table_id = aws_route_table.database.id
    destination_cidr_block = local.default_vpc_cidr
    gateway_id = aws_vpc_peering_connection.peering[count.index].id
}

resource "aws_route" "default_vpc_peering" {
    count = var.is_peering_required ? 1 : 0
    route_table_id = data.aws_route_table.main.route_table_id
    destination_cidr_block = var.vpc_cidr
    gateway_id = aws_vpc_peering_connection.peering[count.index].id
}