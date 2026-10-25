param(
  [Parameter(Mandatory=$true)][string]$WebPublicIp,
  [Parameter(Mandatory=$true)][string]$DbPrivateIp,
  [Parameter(Mandatory=$true)][string]$KeyNameInWsl
)
Write-Host "Use these values when editing ansible/inventory.ini:"
Write-Host "Web public IP: $WebPublicIp"
Write-Host "DB private IP: $DbPrivateIp"
Write-Host "WSL private key path: $KeyNameInWsl"
