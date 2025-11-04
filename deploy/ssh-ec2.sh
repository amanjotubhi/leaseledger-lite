#!/bin/bash
# Quick SSH connection script to your EC2 instance

EC2_KEY="$HOME/.ssh/ec2-keys/AmanUbhi.pem"
EC2_HOST="ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com"

# Check if key exists
if [ ! -f "$EC2_KEY" ]; then
    echo "❌ Key file not found at $EC2_KEY"
    echo "   Run: cp /Users/amanjotubhi/Downloads/AmanUbhi.pem ~/.ssh/ec2-keys/"
    exit 1
fi

# Connect to EC2
ssh -i "$EC2_KEY" "$EC2_HOST"

