#!/bin/bash
set -e

# --------------------------
# System update & tools
# --------------------------
apt-get update -y
apt-get upgrade -y
apt-get install -y wget curl unzip git maven openjdk-21-jdk

# --- NEW: Install AWS CLI v2 ---
echo "Installing AWS CLI v2..."
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
# Verify installation
aws --version
# ------------------------------------------

# Set JAVA_HOME
echo "export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64" >> /etc/profile
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
source /etc/profile

# Verify Java & Maven
java -version
mvn -version

# --------------------------
# Clone the repo
# --------------------------
cd /home/ubuntu
git clone https://github.com/Trainings-TechEazy/test-repo-for-devops.git
cd test-repo-for-devops

# --------------------------
# Clean old target (if exists)
# --------------------------
if [ -d "target" ]; then
  echo "Cleaning old target folder..."
  rm -rf target
fi

# --------------------------
# Build project
# --------------------------
mvn clean package -DskipTests

# --------------------------
# Run the jar dynamically
# --------------------------
JAR_FILE=$(ls target/*.jar | head -n 1)

if [ -f "$JAR_FILE" ]; then
  echo "Running $JAR_FILE ..."
  nohup java -jar "$JAR_FILE" --server.port=80 > app.log 2>&1 &
else
  echo "ERROR: No jar file found in target/"
  exit 1
fi



# --------------------------
# NEW: Upload App Log to S3
# --------------------------
# Wait for a minute to let the app start and generate some logs
sleep 60

# The S3 bucket name is passed in from Terraform as a variable
s3_bucket_name="${s3_bucket_name}"

# Use the AWS CLI to copy the log file to the S3 bucket
aws s3 cp /home/ubuntu/test-repo-for-devops/app.log s3://\${s3_bucket_name}/app/logs/app.log
