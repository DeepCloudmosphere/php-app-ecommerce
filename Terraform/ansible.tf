module "ansible-server" {
  source = "./ansible-server"

  ami-id = data.aws_ami.ec2.id # AMI for an Amazon Linux instance for region: us-east-1

  iam-instance-profile = aws_iam_instance_profile.ansible.id
  key-pair = aws_key_pair.ansible-key.key_name
  name = "ansible"
  device-index = 0
  network-interface-id = aws_network_interface.ansible.id
}
