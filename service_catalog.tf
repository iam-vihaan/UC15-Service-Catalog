# Create a Service Catalog Portfolio
resource "aws_servicecatalog_portfolio" "example" {
  name          = "ExamplePortfolio"
  description   = "Portfolio for example products"
  provider_name = "ExampleProvider"
}

# Create a Service Catalog Product with embedded CloudFormation template
resource "aws_servicecatalog_product" "example" {
  name          = "ExampleProduct"
  owner         = "ExampleOwner"
  description   = "An example product that launches an EC2 instance"
  distributor   = "ExampleDistributor"
  support_description = "Contact support@example.com"
  type          = "CLOUD_FORMATION_TEMPLATE"

  provisioning_artifact_parameters {
    name        = "v1"
    description = "Initial version"
    type        = "CLOUD_FORMATION_TEMPLATE"

    template_body = <<CFT
AWSTemplateFormatVersion: '2010-09-09'
Description: Launches a simple web application on an EC2 instance

Parameters:
  InstanceType:
    Type: String
    Default: t2.micro
    AllowedValues:
      - t2.micro
      - t2.small
      - t3.micro
    Description: EC2 instance type

Resources:
  WebAppSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Enable HTTP access
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0

  WebAppInstance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref InstanceType
      ImageId: ami-0c02fb55956c7d316
      SecurityGroups:
        - !Ref WebAppSecurityGroup
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash
          yum update -y
          yum install -y httpd
          systemctl start httpd
          systemctl enable httpd
          echo "<h1>Welcome to your Web App!</h1>" > /var/www/html/index.html

Outputs:
  WebAppURL:
    Description: Public URL of the web application
    Value: !Sub "http://${WebAppInstance.PublicDnsName}"
CFT
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
