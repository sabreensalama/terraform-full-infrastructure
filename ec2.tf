# create ssh keygen
resource "tls_private_key" "test" {
  algorithm = "RSA"
  rsa_bits = "2048"

}
# attachpublic key  them to ec2
resource "aws_key_pair" "keys" {
  key_name   = "deployer"
  public_key = "${tls_private_key.test.public_key_openssh}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web1" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.keys.key_name}"
  subnet_id = "${aws_subnet.public_subnet1.id}"

  vpc_security_group_ids = ["${aws_security_group.ssh-allowed.id}"]

  tags = {
    Name = "web1"
  }
}

resource "aws_instance" "web2" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.keys.key_name}"
  subnet_id = "${aws_subnet.public_subnet2.id}"

  vpc_security_group_ids = ["${aws_security_group.ssh-allowed.id}"]

  tags = {
    Name = "web2"
  }
}
# create the bestien ec2
resource "aws_instance" "bestien" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.keys.key_name}"
  subnet_id = "${aws_subnet.public_subnet2.id}"

  vpc_security_group_ids = ["${aws_security_group.ssh-allowed.id}"]

  tags = {
    Name = "bestien"
  }
}

# create ec2 in private subnet1 
resource "aws_instance" "proxy1" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.keys.key_name}"
  subnet_id = "${aws_subnet.private_subnet1.id}"

  vpc_security_group_ids = ["${aws_security_group.ssh-allowed.id}"]

  tags = {
    Name = "proxy1"
  }
}

# create ec2 in private subnet1 
resource "aws_instance" "proxy2" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.keys.key_name}"
  subnet_id = "${aws_subnet.private_subnet2.id}"

  vpc_security_group_ids = ["${aws_security_group.ssh-allowed.id}"]

  tags = {
    Name = "proxy2"
  }
}