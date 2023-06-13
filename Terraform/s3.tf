
# S3 Bucket storing jenkins user data

resource "aws_s3_bucket" "config_files" {
  bucket = "ansible-config-files01"
  acl = "private"
}

resource "aws_s3_bucket_object" "ansible-config-files" {
  bucket = aws_s3_bucket.config_files.id
  for_each = fileset("config_files/", "*")
  key = each.value
  source = "config_files/${each.value}"
  etag = filemd5("config_files/${each.value}")
}