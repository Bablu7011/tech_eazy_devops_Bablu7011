#!/bin/bash
set -e

# --------------------------
# System update & tools
# --------------------------
apt-get update -y
apt-get upgrade -y
apt-get install -y wget curl unzip git maven openjdk-21-jdk

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
