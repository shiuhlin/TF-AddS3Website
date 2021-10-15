variable "website_bucket_name" {
  type = string
}

variable "index_file_name" {
  type = string
}

resource "aws_s3_bucket" "websitebucket" {
  bucket = var.website_bucket_name
  
  website {
    index_document = var.index_file_name
    error_document = var.index_file_name
  }

  force_destroy = true
}

resource "aws_s3_bucket_object" "singleobject" {
  bucket = aws_s3_bucket.websitebucket.id
  source = var.index_file_name         # source file name
  key = var.index_file_name            # target file name
  etag = filemd5(var.index_file_name)  # source file name
  content_type = "text/html"           # MIME type
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.websitebucket.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.websitebucket]
}

resource "aws_s3_bucket_policy" "public_website" {  
  bucket = aws_s3_bucket.websitebucket.id   

  policy = jsonencode({
    "Version": "2012-10-17",    
    "Statement": [        
      {            
          "Sid": "PublicReadGetObject",            
          "Effect": "Allow",            
          "Principal": "*",            
          "Action": [                
             "s3:GetObject"            
          ],            
          "Resource": [
             "arn:aws:s3:::${aws_s3_bucket.websitebucket.id}/*"            
          ]        
      }    
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

output "endpoint" {
  value = "http://${aws_s3_bucket.websitebucket.website_endpoint}"
}