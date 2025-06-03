variable "project_name" {
    
}

variable "environment" {
  
}

variable "vpc_cidr" {
    
}

variable "enable_dns_hostnames" {
    default = true
}

# variable "common_tags" { # Since I mentioned default = {}, the  tags become optional
#     type = map
#     default = {}
# }

variable "common_tags" { # This is now mandatory
    type = map
}

variable "vpc_tags" {
    type = map
}

variable "igw_tags" {
    default = {}
}

variable "public_subnet_cidrs" { # here we have mandated to user to give subnet cidr range and limited them to 2 valid subnets
    type = list
    validation {
      condition = length(var.public_subnet_cidrs) == 2
      error_message = "Please provide 2 valid public subnet CIDRs"
    }
}

variable "public_subnet_tags" { # This is optional
    default = {}
}

variable "private_subnet_cidrs" { # here we have mandated to user to give subnet cidr range and limited them to 2 valid subnets
    type = list
    validation {
      condition = length(var.private_subnet_cidrs) == 2
      error_message = "Please provide 2 valid private subnet CIDRs"
    }
}

variable "private_subnet_tags" { # This is optional
    default = {}
}


variable "database_subnet_cidrs" { # here we have mandated to user to give subnet cidr range and limited them to 2 valid subnets
    type = list
    validation {
      condition = length(var.database_subnet_cidrs) == 2
      error_message = "Please provide 2 valid database subnet CIDRs"
    }
}

variable "database_subnet_tags" { # This is optional
    default = {}
}

variable "nat_gateway_tags" {
    default = {}
}

variable "public_route_table_tags" {
    default = {}
}

variable "private_route_table_tags" {
    default = {}
}

variable "database_route_table_tags" {
    default = {}
}

variable "is_peering_required" {
    default = false
}

variable "vpc_peering_tags" {
    default = {}
}