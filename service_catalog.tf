
# Create a Service Catalog Portfolio
resource "aws_servicecatalog_portfolio" "example" {
  name          = "ExamplePortfolio"
  description   = "Portfolio for example products"
  provider_name = "ExampleProvider"
}

# Create a Service Catalog Product
resource "aws_servicecatalog_product" "example" {
  name          = "ExampleProduct"
  owner         = "ExampleOwner"
  description   = "An example product"
  distributor   = "ExampleDistributor"
  support_description = "Contact support@example.com"
  type          = "CLOUD_FORMATION_TEMPLATE"

  provisioning_artifact_parameters {
    name           = "v1"
    description    = "Initial version"
    template_url   = "https://kasi-hcl-bucket-uc8.s3.us-east-1.amazonaws.com/SC-Templeate/CFT.txt"
    type           = "CLOUD_FORMATION_TEMPLATE"
  }
}

resource "aws_iam_role" "service_catalog_launch_role" {
  name = "ServiceCatalogLaunchRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "servicecatalog.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Optional: Attach policies to allow launching resources
resource "aws_iam_role_policy_attachment" "launch_policy" {
  role       = aws_iam_role.service_catalog_launch_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # or a custom policy
}


# Associate an IAM Role with the Portfolio
resource "aws_servicecatalog_principal_portfolio_association" "association" {
  portfolio_id  = aws_servicecatalog_portfolio.example.id
  principal_arn = "arn:aws:iam::784733659029:role/SC-role"
}

# Add a Launch Constraint to the Product
resource "aws_servicecatalog_constraint" "launch_role" {
  portfolio_id = aws_servicecatalog_portfolio.example.id
  product_id   = aws_servicecatalog_product.example.id
  type         = "LAUNCH"

  parameters = jsonencode({
    RoleArn = "arn:aws:iam::784733659029:role/SC-role"
  })

  depends_on = [
    aws_servicecatalog_portfolio.example,
    aws_servicecatalog_product.example
  ]
}

