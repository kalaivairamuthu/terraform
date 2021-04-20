// An Azure resource group

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_security_group" "ingress-all" {
  name = "allow-all-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  // Terraform removes the default rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_subnet" "subnet1" {
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 1)
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.aws_availability_zone
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = [
      "hvm"]
  }
  owners = [
    "099720109477"]
  # Canonical
}

resource "aws_instance" "default" {
  ami = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [
    aws_security_group.ingress-all.id]
  subnet_id = aws_subnet.subnet1.id
  user_data = data.template_file.user_data.rendered
  tags = {
    Name = var.hostname
  }

  connection {
    user = "ubuntu"
    password = var.password
    //private_key = var.key_name
    agent = false
    host = aws_instance.default.public_ip
  }

  provisioner "file" {
    source = "install_arc_agent.sh"
    destination = "/tmp/install_arc_agent.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y python-ctypes",
      "sudo chmod +x /tmp/install_arc_agent.sh",
      "/tmp/install_arc_agent.sh",
    ]
  }
  provisioner "file" {
    source = "log_analytics_agent.sh"
    destination = "/tmp/log_analytics_agent.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/log_analytics_agent.sh",
      "/tmp/log_analytics_agent.sh",
    ]
  }

}

resource "local_file" "install_arc_agent_sh" {
  content = templatefile("install_arc_agent.sh.tmpl", {
    resourceGroup = var.azure_resource_group
    location = var.azure_location
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
    subscription_id = var.subscription_id
  }
  )
  filename = "install_arc_agent.sh"
}

resource "local_file" "log_analytics_agent_sh" {
  content = templatefile("log_analytics_agent.sh.tmpl", {
    Workspace_Id = var.Workspace_Id
    Workspace_Key = var.Workspace_Key
  }
  )
  filename = "log_analytics_agent.sh"
}


data "template_file" "user_data" {
  template = templatefile("user_data.tmpl", {
    hostname = var.hostname
    username = "ubuntu"
    password = var.password
  }
  )
}

// A variable for extracting the external ip of the instance
output "ip" {
  value = aws_instance.default.public_ip
}
