
# S3 Bucket storing jenkins user data

resource "aws_s3_bucket" "playbooks" {
  bucket = "ansible-playbooks01"
  acl = "private"
}

resource "aws_s3_bucket_object" "ansible-playbooks-files" {
  bucket = aws_s3_bucket.playbooks.id
  for_each = fileset("playbooks/", "*")
  key = each.value
  source = "playbooks/${each.value}"
  etag = filemd5("playbooks/${each.value}")
}