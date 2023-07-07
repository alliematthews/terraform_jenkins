provider "aws" {
  region = "us-east-1"
}

# Defining Our EC2 Instance to Deploy in Our Default VPC
resource "aws_instance" "instance_1" {
  ami           = "ami-090e0fc566929d98b"
  instance_type = "t2.micro"

  tags = {
    Name = "terraform_jenkins_instance"
  }

#The bootstrap script needed to install and start Jenkins
user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
  sudo yum upgrade
  sudo amazon-linux-extras install java-openjdk11 -y
  sudo yum install jenkins -y
  sudo systemctl enable jenkins
  sudo systemctl start jenkins
  EOF
}

#Create and assign a security group to Jenkins Security Group
resource "aws_security_group" "tf_jenkins_sg" {
  name        = "tf_jenkins_sg"
  description = "Allow SSH, Inbound, and Jenkins Traffic"

  #Allow incoming traffic from port 22 from any IP address
  ingress {
    description = "Incoming SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Allow incoming traffic from port 8080 from any IP address
  ingress {
    description = "Incoming 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow incoming TCP requests on port 443 from any IP address
  ingress {
    description = "Incoming 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-jenkins"
  }

#Create an S3 bucket for Jenkins Artifacts
resource "aws_s3_bucket" "jenkins_artifacts_wk20" {
  bucket = "allie-matthews-wk20-jenkins_artifacts_bucket"
  acl    = "private"

}

