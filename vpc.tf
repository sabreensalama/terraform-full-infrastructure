resource "aws_vpc" "terra_vpc" {
    cidr_block="${var.cidr}"
  tags={
        Name = "${var.tag}"

  }
}

resource "aws_internet_gateway" "iti_igw" {
    # to attach ig to vpc
    vpc_id= "${aws_vpc.terra_vpc.id}"
       tags = {
        Name = "prod-igw"
    }

}
# subnet :puplic
resource "aws_subnet" "public_subnet1" {
    vpc_id= "${aws_vpc.terra_vpc.id}"
    cidr_block = "${var.public_subnet1}"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "${var.azs1}"

}

resource "aws_subnet" "public_subnet2" {
    vpc_id= "${aws_vpc.terra_vpc.id}"
    cidr_block = "${var.public_subnet2}"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "${var.azs2}"

}


#public route table and associate it with gateway
resource "aws_route_table" "public_rt" {
    vpc_id="${aws_vpc.terra_vpc.id}"
    route{
        cidr_block="0.0.0.0/0"
        gateway_id="${aws_internet_gateway.iti_igw.id}"
    }

}

# route table association with puplic subnet
# length to make loop on two subnet
# element to get one id
resource "aws_route_table_association" "rtass1" {
    subnet_id="${aws_subnet.public_subnet1.id}"
    route_table_id = "${aws_route_table.public_rt.id}"

}

resource "aws_route_table_association" "rtass2" {
    subnet_id="${aws_subnet.public_subnet2.id}"
    route_table_id = "${aws_route_table.public_rt.id}"

}

# subnets : private
resource "aws_subnet" "private_subnet1" {
    vpc_id= "${aws_vpc.terra_vpc.id}"
    cidr_block = "${var.subnet_private1}"
    availability_zone = "${var.azs1}" 
}
resource "aws_subnet" "private_subnet2" {
    vpc_id= "${aws_vpc.terra_vpc.id}"
    cidr_block = "${var.subnet_private2}"
    availability_zone = "${var.azs2}" 
}



# route table private
resource "aws_route_table" "private_rt" {
    vpc_id = "${aws_vpc.terra_vpc.id}"
        tags =  {
        Name = "Local Route Table for Isolated Private Subnet"
    }

}

# route table association with private
resource "aws_route_table_association" "rtpv" {
    subnet_id="${aws_subnet.private_subnet1.id}"
    route_table_id = "${aws_route_table.private_rt.id}"

}

resource "aws_route_table_association" "rtpv1" {
    subnet_id="${aws_subnet.private_subnet2.id}"
    route_table_id = "${aws_route_table.private_rt.id}"

}


resource "aws_security_group" "ssh-allowed" {
    vpc_id = "${aws_vpc.terra_vpc.id}"
    

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"

        cidr_blocks = ["0.0.0.0/0"]
    }

    tags  = {
        Name = "ssh-allowed"
    }
}