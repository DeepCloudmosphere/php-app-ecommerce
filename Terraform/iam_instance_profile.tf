# Web App 

resource "aws_iam_instance_profile" "ansible" {
  name = "ansible"
  role = aws_iam_role.ansible.name
}

resource "aws_iam_role" "ansible" {
  name = "ansible"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [aws_iam_policy.ecr-access.arn,
                        aws_iam_policy.ec2-access.arn,
                        aws_iam_policy.s3-access.arn]
}


# Jenkins

resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins"
  role = aws_iam_role.jenkins.name
}

resource "aws_iam_role" "jenkins" {
  name = "jenkins"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [aws_iam_policy.ec2-access.arn]
}


