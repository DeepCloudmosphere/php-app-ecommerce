# SSH key - Web App

resource "aws_key_pair" "ansible-key" {
  key_name = "ansible"
  public_key = file("./ansible.pem")
}

# SSH key - Jenkins

resource "aws_key_pair" "jenkins-key" {
  key_name = "jenkins"
  public_key = file("./jenkins.pem")
}