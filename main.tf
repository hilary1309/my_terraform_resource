# Create an S3 bucket using a variable for the bucket name
resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname  # The bucket name is dynamically set via a Terraform variable
}

# Set ownership controls for the S3 bucket
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.mybucket.id  # Reference the ID of the created S3 bucket

  rule {
    object_ownership = "BucketOwnerPreferred"  # Ensures that the bucket owner has ownership over all objects, even if uploaded by another AWS account
  }
}

# Configure public access settings for the S3 bucket
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mybucket.id  # Reference the ID of the created S3 bucket

  # Set public access block configuration for the bucket:
  block_public_acls       = false    # Do not block public ACLs, allowing the use of public ACLs
  block_public_policy     = false    # Do not block public bucket policies, allowing the use of public policies
  ignore_public_acls      = false    # Public ACLs are not ignored, so they will be enforced if set
  restrict_public_buckets = false    # Public bucket settings are not restricted, allowing the bucket to be publicly accessible
}

# Set the ACL (Access Control List) for the S3 bucket
resource "aws_s3_bucket_acl" "example" {
  depends_on = [  # Ensure the bucket ownership controls and public access block settings are applied first
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.mybucket.id  # Reference the ID of the created S3 bucket
  acl    = "public-read"  # Set the bucket to be publicly readable
}

# Upload the index.html file
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
}

# Upload the error.html file
resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "error.html"
  source = "error.html"
  acl = "public-read"
  content_type = "text/html"
}

# Upload all images dynamically using for_each
resource "aws_s3_object" "images" {
  for_each = zipmap(var.images, var.images)
  bucket = aws_s3_bucket.mybucket.id
  key    = each.value
  source = each.value
  acl = "public-read"
}

# Upload the index.css file (for index.html)
resource "aws_s3_object" "index_css" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "style.css"
  source = "style.css"
  acl    = "public-read"
  content_type = "text/css"
}

# Upload the error.css file (for error.html)
resource "aws_s3_object" "error_css" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "404styles.css"
  source = "404styles.css"
  acl    = "public-read"
  content_type = "text/css"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [ aws_s3_bucket_acl.example ]
}