data "aws_ami" "ubuntu-ami" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_network_interface" "Matrix-Instance-NetworkInterface" {
  subnet_id = var.PublicSubnet
  security_groups = [var.Matrix-SecG]
}

resource "aws_eip" "ElasticIP" {
  vpc = true
}

resource "aws_instance" "Matrix-Instance" {
  ami = data.aws_ami.ubuntu-ami.id
  instance_type = "t2.micro"
  iam_instance_profile = var.SSM-Instance-Profile
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.Matrix-Instance-NetworkInterface.id
  }

  tags = {
    Name = "Matrix-Instance"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.Matrix-Instance.id
  allocation_id = aws_eip.ElasticIP.id
}
