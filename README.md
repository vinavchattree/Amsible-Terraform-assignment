# TravelMemory deployment using Terraform + Ansible (AWS Mumbai)

This starter project provisions the assignment's required two-instance architecture:
- Public subnet: one Ubuntu 22.04 EC2 instance hosting React build, Nginx, and the Node/Express API.
- Private subnet: one Ubuntu 22.04 EC2 instance hosting MongoDB.
- VPC, Internet Gateway, NAT Gateway, public/private route tables, security groups, EC2 IAM instance profile, and Terraform outputs.
- Ansible configures MongoDB and deploys the application.

## Requirements
- AWS account permissions for VPC, EC2, EIP, NAT Gateway, IAM role/profile, and security groups.
- AWS CLI v2 and Terraform installed on Windows.
- Ansible installed in WSL2 Ubuntu.
- Existing EC2 key pair in `ap-south-1`; the matching private PEM file must be available inside WSL.
- Current public IPv4 address for SSH restriction.

## 1. Configure AWS CLI (PowerShell)
```powershell
aws configure
aws sts get-caller-identity
terraform -version
```
Use an IAM identity with only the permissions required for this assignment. Never commit credentials or paste them into chat.

## 2. Create Terraform variables
From the project root:
```powershell
Copy-Item terraform/terraform.tfvars.example terraform/terraform.tfvars
$myIp = (Invoke-RestMethod -Uri "https://checkip.amazonaws.com").Trim()
Write-Host "Your public IP is $myIp"
notepad terraform/terraform.tfvars
```
Edit `terraform/terraform.tfvars`:
- `key_name`: existing EC2 key-pair name shown in AWS EC2 > Key pairs (not the PEM filename).
- `my_ip_cidr`: replace with the value `$myIp/32`, e.g. `203.0.113.25/32`.
- Confirm `aws_region = "ap-south-1"` and `availability_zone = "ap-south-1a"`. If the chosen key pair or capacity is unavailable in that AZ, select another AZ in ap-south-1.

Then:
```powershell
Set-Location terraform
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```
Type `yes` only after reviewing the plan. Save outputs:
```powershell
terraform output
terraform output -raw web_public_ip
terraform output -raw db_private_ip
```
Do not commit `terraform.tfstate` or `.terraform/`.

## 3. Prepare Ansible in WSL2
Install WSL2 Ubuntu if not already available, then in the WSL terminal:
```bash
sudo apt update
sudo apt install -y ansible git python3-pip
ansible --version
mkdir -p ~/.ssh
```
Copy your existing Windows PEM key into WSL. Example (replace Windows username and PEM filename):
```bash
cp /mnt/c/Users/YOUR_WINDOWS_USER/Downloads/YOUR_KEY.pem ~/.ssh/travelmemory.pem
chmod 600 ~/.ssh/travelmemory.pem
```
Keep the PEM private. Do not put it in the repository.

Copy the project into the WSL filesystem or access it via `/mnt/c/...`. Running from WSL filesystem (e.g. `~/travelmemory-terraform-ansible`) is usually faster.

## 4. Configure Ansible files
From project root (WSL):
```bash
cp ansible/inventory.ini.example ansible/inventory.ini
cp ansible/group_vars/all.yml.example ansible/group_vars/all.yml
```
Edit `ansible/inventory.ini`:
- web host = Terraform `web_public_ip`
- db host = Terraform `db_private_ip`
- replace `~/.ssh/REPLACE_WITH_KEY.pem` with `/home/YOUR_WSL_USER/.ssh/travelmemory.pem`
- replace `REPLACE_WITH_WEB_PUBLIC_IP` in the DB `ProxyJump` with the web public IP.

Edit `ansible/group_vars/all.yml` and set a long random alphanumeric `mongo_app_password`. Avoid punctuation in this emergency assignment to prevent URI encoding issues. The real `all.yml` is ignored by Git.

Test SSH:
```bash
ansible -i ansible/inventory.ini web -m ping
ansible -i ansible/inventory.ini db -m ping
```
The DB ping uses the public web instance as an SSH jump host. If it fails, see Troubleshooting.

## 5. Deploy
From project root in WSL:
```bash
ansible-playbook -i ansible/inventory.ini ansible/site.yml --syntax-check
ansible-playbook -i ansible/inventory.ini ansible/site.yml
```

Expected API response: `Hello World!`

## Architecture / security notes
- MongoDB is not assigned a public IP and has no inbound rule from the internet.
- Security group allows port 27017 only from the web/app security group.
- SSH to web is restricted to your public IP /32; SSH to DB is allowed only from the web security group and uses ProxyJump.
- Nginx serves the production React build and proxies `/api/*` to the local Express service on port 3001. Port 3001 is not exposed publicly.
- MongoDB authorization is enabled and the application account has `readWrite` only on the `travelmemory` database.
- EC2 IAM role has AmazonSSMManagedInstanceCore for Systems Manager. The app itself does not need AWS API permissions.
- This is an assignment environment, not a fully production-hardened service: add HTTPS, secret management (e.g. Secrets Manager), backups, patching, and monitoring before real production use.

## Troubleshooting
### `terraform apply` says key pair not found
The key pair must exist in `ap-south-1`. `key_name` is the AWS key-pair name, not the local PEM filename.

### SSH timeout to public EC2
Update `my_ip_cidr` if your public IP changed. Re-run `terraform apply`. Verify inbound TCP/22 and the key permissions.

### Ansible cannot reach private DB
Check:
- public host SSH works first;
- DB host is the private IP;
- inventory's `ProxyJump` uses the correct public IP;
- the same private key is specified for both hosts;
- DB security group permits SSH from the web security group.
Run `ssh -i ~/.ssh/travelmemory.pem -J ubuntu@WEB_PUBLIC_IP ubuntu@DB_PRIVATE_IP`.

### MongoDB apt/install issue
This project uses Ubuntu 22.04 and MongoDB's official 8.0 Jammy repository. Official docs list Ubuntu 22.04 as supported: https://www.mongodb.com/docs/v8.0/tutorial/install-mongodb-on-ubuntu/

### Frontend builds but API requests fail
Check:
```bash
sudo systemctl status travelmemory-backend --no-pager
sudo journalctl -u travelmemory-backend -n 100 --no-pager
sudo nginx -t
sudo tail -n 100 /var/log/nginx/error.log
```
Verify `http://WEB_PUBLIC_IP/api/hello` returns `Hello World!`.

### Application says Mongo authentication failed
Check `ansible/group_vars/all.yml` and backend `.env` on the server. Re-run playbook after correcting credentials. Never paste passwords into GitHub or chat.

## 6. Deliverables checklist
- [ ] `terraform/` files committed
- [ ] `ansible/site.yml`, `ansible.cfg`, and example inventory/variables committed  
- [ ] Screenshot of the working app in browser
- [ ] GitHub repository link submitted through Vlearn

## 7. Cleanup after submission
If the environment is no longer needed, from `terraform/`:
```powershell
terraform destroy
```
Review the plan and type `yes`. This removes resources managed by this state, including NAT Gateway and EIP. Keep your code and evidence first.
