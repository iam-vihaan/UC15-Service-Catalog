
resource "aws_servicecatalog_portfolio" "web_app_portfolio" {
  name          = "WebAppPortfolio"
  description   = "Portfolio for launching web applications"
  provider_name = "My-Comp"
}

resource "aws_servicecatalog_product" "web_app_product" {
  name        = "WebAppProduct"
  owner       = "My-Comp"
  description = "Launch a web application"
  distributor = "My-Comp"
  type        = "CLOUD_FORMATION_TEMPLATE"

  provisioning_artifact_parameters {
    name         = "v1"
    description  = "Initial version"
    template_url = "https://kasi-hcl-bucket-uc8.s3.us-east-1.amazonaws.com/SC-Templeate/CFT.txt"
    type         = "CLOUD_FORMATION_TEMPLATE"
  }
}

resource "aws_servicecatalog_principal_portfolio_association" "association" {
  portfolio_id = aws_servicecatalog_portfolio.web_app_portfolio.id
  product_id   = aws_servicecatalog_product.web_app_product.id
}

resource "aws_servicecatalog_constraint" "launch_role" {
  portfolio_id = aws_servicecatalog_portfolio.web_app_portfolio.id
  product_id   = aws_servicecatalog_product.web_app_product.id
  role_arn     = "arn:aws:iam::123456789012:role/ServiceCatalogLaunchRole"
}
