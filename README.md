# Multi-Service E-Commerce Deployment with Terraform & Docker

This repository contains a Node.js-based multi-service e-commerce application, fully containerized with Docker and deployable on AWS EC2 using Terraform. The application consists of:

- **Backend Services**:
  - User Service (`user-service`)
  - Products Service (`products-service`)
  - Orders Service (`orders-service`)
  - Cart Service (`cart-service`)
- **Frontend Service**:
  - React application (`frontend`)

All services are Dockerized, pulled from DockerHub, and run on a single Ubuntu EC2 instance.

---

## Table of Contents

1. [Prerequisites](#prerequisites)  
2. [Directory Structure](#directory-structure)  
3. [Step 1: Build & Push Docker Images](#step-1-build--push-docker-images)  
4. [Step 2: Terraform Deployment](#step-2-terraform-deployment)  
5. [Step 3: Verify Deployment](#step-3-verify-deployment)  
6. [Step 4: Destroy Infrastructure](#step-4-destroy-infrastructure)  
7. [Troubleshooting](#troubleshooting)  

---

## Prerequisites

Before starting, ensure you have:

1. **AWS account** with credentials configured locally (`aws configure`).  
2. **Terraform v1.0+** installed.  
3. **Docker** installed locally.  
4. **DockerHub account** for pushing images.  
5. **EC2 key pair** in your AWS region for SSH access.  
6. Node.js & npm installed (for frontend build).  
7. Public IP of your machine (for SSH access) if restricting SSH.

---

## Directory Structure

```text
.
├── user-service/
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── products-service/
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── orders-service/
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── cart-service/
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── frontend/
│   ├── src/
│   ├── package.json
│   └── Dockerfile
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── user-data.tpl
    └── terraform.tfvars
```
---
## Step 1: Build & Push Docker Images

1. Navigate to each service directory and build the Docker images:

   ```bash
   cd user-service
   docker build -t YOUR_DOCKERHUB_USER/user-service:latest .
   docker push YOUR_DOCKERHUB_USER/user-service:latest
   cd ../products-service
   docker build -t YOUR_DOCKERHUB_USER/products-service:latest .
   docker push YOUR_DOCKERHUB_USER/products-service:latest
   cd ../orders-service
   docker build -t YOUR_DOCKERHUB_USER/orders-service:latest .
   docker push YOUR_DOCKERHUB_USER/orders-service:latest
   cd ../cart-service
   docker build -t YOUR_DOCKERHUB_USER/cart-service:latest .
   docker push YOUR_DOCKERHUB_USER/cart-service:latest
   cd ../frontend
   npm install
   npm run build
   docker build -t YOUR_DOCKERHUB_USER/frontend:latest .
   docker push YOUR_DOCKERHUB_USER/frontend:latest
   ```
    Replace `YOUR_DOCKERHUB_USER` with your actual DockerHub username.

    ![user-service](/images/1.png "Optional Title")
    ![product-service](/images/2.png "Optional Title")
    ![orders-service](/images/3.png "Optional Title")
    ![cart-service](/images/4.png "Optional Title")
    ![frontend-service](/images/5.png "Optional Title")

    Frontend Dockerfile uses multi-stage build and serves React app on port 80.

    ![frontend-dockerfile](/images/6.png "Optional Title")

2. Push the docker images
    ```bash
    docker push YOUR_DOCKERHUB_USER/user-service:latest
    docker push YOUR_DOCKERHUB_USER/products-service:latest
    docker push YOUR_DOCKERHUB_USER/orders-service:latest
    docker push YOUR_DOCKERHUB_USER/cart-service:latest
    docker push YOUR_DOCKERHUB_USER/frontend:latest
    ```
    Replace `YOUR_DOCKERHUB_USER` with your actual DockerHub username.

    ![user-service](/images/7.png "Optional Title")
    ![product-service](/images/8.png "Optional Title")
    ![orders-service](/images/9.png "Optional Title")
    ![cart-service](/images/10.png "Optional Title")
    ![frontend-service](/images/11.png "Optional Title")
---

## Step 2: Terraform Deployment
1. Navigate to the `terraform` directory:

   ```bash
   cd ../terraform
   ```
2. Update `terraform.tfvars` with your configurations:
    ```terraform
    key_name         = "your-ec2-key
    dockerhub_user   = "YOUR_DOCKER
    image_tag        = "latest"
    allowed_ssh_cidr = "YOUR.IP.ADD"
    allowed_cidr     = ""
    instance_type    = "t3.micro"
    region           = "your-aws-region"
    ```
3. Initialize Terraform:
    ```bash
    terraform init
    ```
    ![terraform-init](/images/12.png "Optional Title")

4. Review the plan:
    ```bash
    terraform plan -out plan.tfplan
    ```
    ![terraform-plan](/images/13.png "Optional Title")

5. Apply the plan:
    ```bash
    terraform apply plan.tfplan
    ```
    ![terraform-apply-plan](/images/14.png "Optional Title")

    Note the public IP output after apply completes.

    ![terraform-apply](/images/15.png "Optional Title")

    Terraform will provision:
    
    - VPC, Subnet, Internet Gateway, Route Table
    - Security Group with HTTP (80) and internal ports (3001-3004)
    - Ubuntu EC2 instance
    - Docker installed + all 5 containers pulled and running via user-data script

    ![terraform-resources](/images/17.png "Optional Title")

    The user-data script (`user-data.tpl`) handles Docker installation and container setup.
---
## Step 3: Verify Deployment
1. Access the application in your browser:
   ```
   http://<EC2_PUBLIC_IP>
   ```
   Replace `<EC2_PUBLIC_IP>` with the public IP output from Terraform.

   ![app-home](/images/16.png "Optional Title")

2. You should see the e-commerce frontend. Test the functionality by adding products to the cart and placing orders.
---
## Step 4: Destroy Infrastructure
1. When done, destroy the infrastructure to avoid ongoing costs:
   ```bash
   terraform destroy -auto-approve
   ```
   Confirm the destruction when prompted.

   ![terraform-destroy](/images/18.png "Optional Title")
---
## Troubleshooting
- If the application doesn't load, check the EC2 instance status and security group rules in the AWS Console.
- SSH into the instance to check Docker container statuses:
  ```bash
  ssh -i path/to/your-key.pem ubuntu@<EC2_PUBLIC_IP>
  docker ps -a
  ```
    - Check logs for any container issues:
    ```bash
    docker logs <container_id>
    ```
    - Ensure Docker is running:
    ```bash
    sudo systemctl status docker
    ```
    - Restart Docker if needed:
    ```bash
    sudo systemctl restart docker
    ```
---

# Notes
- Ensure your AWS credentials have sufficient permissions for EC2 and VPC operations.
- Modify security group rules as needed for your use case.
- All services run on a single EC2 instance to simplify deployment.
- Ports:
    - Frontend: 80
    - User: 3001
    - Products: 3002
    - Orders: 3003
    - Cart: 3004
- DockerHub images must be public for EC2 `docker pull` to succeed.
- All configurations are reproducible with `terraform apply`.
---

# Author
<p align="center">
  <a href="https://github.com/sainathislavath">
    <img src="https://avatars.githubusercontent.com/u/71361447?v=4&s=40" width="50" style="border-radius:50%;">
    <br>
    <b>Sainath Islavath</b>
  </a>
</p>
