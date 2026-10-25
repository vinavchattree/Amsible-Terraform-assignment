# Run from the project root in PowerShell.
$ErrorActionPreference = "Stop"

aws sts get-caller-identity
if (-not (Test-Path "terraform/terraform.tfvars")) {
    Copy-Item "terraform/terraform.tfvars.example" "terraform/terraform.tfvars"
    Write-Host "Edit terraform/terraform.tfvars with key_name and my_ip_cidr, then rerun."
    exit 1
}

Push-Location terraform
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform output
Pop-Location
