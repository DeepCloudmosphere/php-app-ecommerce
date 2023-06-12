
# 6.1 Create a Security Group for inbound web traffic

resource "aws_security_group" "allow-web-traffic" {
  name = "allow-web-traffic"
  description = "Allow HTTP / HTTPS inbound traffic"
  vpc_id = aws_vpc.k8svpc.id

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 6.2 Create a Security Group for inbound ssh

resource "aws_security_group" "allow-ssh-traffic" {
  name = "allow-ssh-traffic"
  description = "Allow SSH inbound traffic"
  vpc_id = aws_vpc.k8svpc.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 6.3 Create a Security Group for inbound traffic to Jenkins

resource "aws_security_group" "allow-jenkins-traffic" {
  name = "allow-jenkins-traffic"
  description = "Allow jenkins inbound traffic"
  vpc_id = aws_vpc.k8svpc.id

  ingress {
    description = "Jenkins"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# 6.5 Create a Security Group for outbound traffic

resource "aws_security_group" "allow-all-outbound" {
  name = "allow-all-outbound"
  description = "Allow all outbound traffic"
  vpc_id = aws_vpc.k8svpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}








# 7.1 Create a Network Interface for jenkins

resource "aws_network_interface" "jenkins" {
  subnet_id = aws_subnet.public-us-east-1a.id
  private_ips = ["192.168.64.50"]
  security_groups = [aws_security_group.allow-all-outbound.id,
                     aws_security_group.allow-ssh-traffic.id, 
                     aws_security_group.allow-jenkins-traffic.id]
}

# 7.2 Create a Network Interface for nodejs Web App

resource "aws_network_interface" "ansible" {
  subnet_id = aws_subnet.public-us-east-1b.id
  private_ips = ["192.168.96.51"]
  security_groups = [ aws_security_group.allow-all-outbound.id,
                      aws_security_group.allow-ssh-traffic.id]
}
# 8.1 Assign an Elastic IP to the Network Interface of Jenkins

resource "aws_eip" "jenkins-eip" {
  vpc = true
  network_interface = aws_network_interface.jenkins.id
  associate_with_private_ip = "192.168.64.50"
  depends_on = [
    aws_internet_gateway.k8svpc-igw # it depends on the internet gateway (as the terraform page says, the elastic ip may require the internet gateway to already exist).
  ]
}
# 8.2 Assign an Elastic IP to the Network Interface of Simple Web App

resource "aws_eip" "ansible-eip" {
  vpc = true
  network_interface = aws_network_interface.ansible.id
  associate_with_private_ip = "192.168.96.51"
  depends_on = [
    aws_internet_gateway.k8svpc-igw
  ]
}