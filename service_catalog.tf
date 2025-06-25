
# Upload the CloudFormation template to S3
resource "aws_s3_bucket" "kasi-SC-bucket" {
  bucket = "kasi-SC-bucket"
}

resource "aws_s3_bucket_object" "template" {
  bucket = aws_s3_bucket.kasi-SC-bucket
  key    = "ec2-webapp-template.yaml"
  source = "ec2-webapp-template.yaml"
  etag   = filemd5("ec2-webapp-template.yaml")
}

# Create a Service Catalog Portfolio
resource "aws_servicecatalog_portfolio" "example" {
  name          = "ExamplePortfolio"
  description   = "Portfolio for example products"
  provider_name = "ExampleProvider"
}

# Create a Service Catalog Product using the uploaded template
resource "aws_servicecatalog_product" "example" {
  name          = "ExampleProduct"
  owner         = "ExampleOwner"
  description   = "An example product that launches an EC2 instance"
  distributor   = "ExampleDistributor"
  support_description = "Contact support@example.com"
  type          = "CLOUD_FORMATION_TEMPLATE"

  provisioning_artifact_parameters {
    name           = "v1"
    description    = "Initial version"
    template_url   = "https://${aws_s3_bucket.example.bucket}.s3.amazonaws.com/${aws_s3_bucket_object.template.key}"
    type           = "CLOUD_FORMATION_TEMPLATE"
  }
}

# Associate an IAM Role with the Portfolio
resource "aws_servicecatalog_principal_portfolio_association" "association" {
  portfolio_id  = aws_servicecatalog_portfolio.example.id
  principal_arn = "arn:aws:iam::784733659029:role/Service-Catalog"
}

# Associate the Product with the Portfolio
resource "aws_servicecatalog_product_portfolio_association" "example" {
  portfolio_id = aws_servicecatalog_portfolio.example.id
  product_id   = aws_servicecatalog_product.example.id
}

# Add a Launch Constraint to the Product
resource "aws_servicecatalog_constraint" "launch_role" {
  portfolio_id = aws_servicecatalog_portfolio.example.id
  product_id   = aws_servicecatalog_product.example.id
  type         = "LAUNCH"

  parameters = jsonencode({
    RoleArn = "arn:aws:iam::784733659029:role/Service-Catalog"
  })

  depends_on = [
    aws_servicecatalog_portfolio.example,
    aws_servicecatalog_product.example,
    aws_servicecatalog_product_portfolio_association.example
  ]
}
