# TravelMemory MERN Application Deployment using Terraform and Ansible

## 1. Objective
Deploy the TravelMemory MERN application on AWS using Terraform for infrastructure provisioning and Ansible for configuration management.

## 2. Architecture
- AWS region: ap-south-1 (Mumbai)
- VPC CIDR: 10.20.0.0/16
- Public subnet: 10.20.1.0/24
- Private subnet: 10.20.2.0/24
- Public EC2: Nginx, React production build, Node.js/Express API
- Private EC2: MongoDB
- Internet Gateway: inbound/outbound internet route for public subnet
- NAT Gateway: outbound internet access for private subnet
- Security groups: SSH restricted to operator IP; MongoDB accessible only from application security group
- IAM: EC2 instance profile with AmazonSSMManagedInstanceCore

## 3. How components interact
1. User opens the public EC2 address over HTTP on port 80.
2. Nginx serves the React static production build.
3. Frontend API requests use the same-origin `/api` path.
4. Nginx proxies `/api/*` requests to Express on `127.0.0.1:3001`.
5. Express uses the `MONGO_URI` environment variable to connect to MongoDB using an application user.
6. MongoDB listens on loopback and the DB private IP; the security group permits TCP/27017 only from the web instance's security group.
7. Terraform provisions infrastructure; Ansible installs packages and configures both instances.

## 4. Terraform implementation
Document the VPC, subnets, route tables, IGW, NAT Gateway, EIP, security groups, IAM role/profile, EC2 instances, AMI lookup, encrypted EBS volumes, IMDSv2 requirement, and outputs.

## 5. Ansible implementation
Describe idempotent tasks for MongoDB repository/package installation, bind address and authorization, database user creation, Node.js/Nginx installation, repository checkout, npm dependencies, React build, systemd backend service, and Nginx reverse proxy.

## 6. Validation evidence
Fill in actual results; do not claim a check passed unless you ran it.
- `terraform validate`: [PASS/FAIL + output]
- `ansible-playbook --syntax-check`: [PASS/FAIL + output]
- `ansible-playbook`: [PASS/FAIL + output]
- `http://<web-public-ip>/`: [PASS/FAIL]
- `http://<web-public-ip>/api/hello`: [PASS/FAIL; expected body: Hello World!]
- MongoDB connectivity/authentication: [describe evidence]
- Security group and subnet checks: [describe evidence]

## 7. Screenshots
Insert screenshots for:
1. Terraform outputs
2. VPC and subnets / route tables
3. EC2 instances showing public and private placement
4. Security group inbound rules
5. Working application in browser
6. `/api/hello` health endpoint
7. Ansible successful play recap

## 8. Conclusion
Summarize the outcome, challenges encountered, and what was learned. Include only verified outcomes.
