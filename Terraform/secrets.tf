
# ansible secrets
resource "aws_secretsmanager_secret" "ansible" {
  name = "ansible"
  recovery_window_in_days=0
}

resource "aws_secretsmanager_secret_version" "ansible" {
  secret_id = aws_secretsmanager_secret.ansible.id
  secret_string = jsonencode(var.ansibleSecrets)
}

# jenkins secrets
resource "aws_secretsmanager_secret" "jenkins" {
  name = "jenkins"
  recovery_window_in_days=0
}

resource "aws_secretsmanager_secret_version" "jenkins" {
  secret_id = aws_secretsmanager_secret.jenkins.id
  secret_string = jsonencode(var.jenkinsSecrets)
}