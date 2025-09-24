DevOps Assignment – Automate EC2 Deployment

This project demonstrates how to automate the provisioning of an EC2 instance on AWS using Terraform.

🚀 Steps to Deploy
1. Configure AWS CLI

Run the following command and provide your AWS Access Key, Secret Key, Region, and Output format:

aws configure

2. Create an SSH Key

Generate an SSH key locally:

ssh-keygen -t rsa -b 2048 -f ~/.ssh/mykey


Import the public key into AWS:

aws ec2 import-key-pair \
  --key-name "mykey" \
  --public-key-material fileb://~/.ssh/mykey.pub

3. Set Environment Variable for Key Name

Avoid hardcoding the key in Terraform. Instead, export it as an environment variable:

export TF_VAR_key_name="mykey"

4. Deploy Infrastructure with Terraform

Go to the Terraform directory and run:

cd terraform
terraform init
terraform apply -auto-approve

5. Get Public IP of EC2

After deployment, fetch the public IP:

terraform output ec2_public_ip

6. Test in Browser

Open your browser and visit:

http://<PUBLIC_IP>

7. Destroy Resources After Testing

To avoid unnecessary costs, destroy the infrastructure when no longer needed:

terraform destroy -auto-approve