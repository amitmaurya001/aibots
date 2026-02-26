#!/usr/bin/bash
set -o errexit
set -o nounset

#For debugging use: /var/log/cloud-init-output.log

echo 'Udemy bash script - package installation start'
sudo apt-get update
sudo apt install -y docker.io unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
echo 'Udemy bash script - package installation end'

echo 'Udemy bash script - docker group start'
sudo usermod -aG docker ubuntu
echo 'Udemy bash script - docker group end'

#https://unix.stackexchange.com/questions/95988/setting-variables-inside-subshell-when-using
newgrp docker <<'EOF'
export ECR_URI="${account_id}.dkr.ecr.${region}.amazonaws.com"
export IMAGE_ID=$ECR_URI/${app_name}:latest

echo 'Udemy bash script - docker login&pull start'
docker login -u AWS -p $(aws ecr get-login-password --region ${region}) $ECR_URI
docker pull $IMAGE_ID
echo 'Udemy bash script - docker login&pull end'

docker run -p 80:5000 \
        --name ${app_name} \
        --restart always \
        --env "AWS_DEFAULT_REGION=${region}" \
        --log-driver=awslogs \
        --log-opt awslogs-region=${region} \
        --log-opt awslogs-group=${app_name} \
        --log-opt awslogs-create-group=true \
        --log-opt awslogs-multiline-pattern='^MONIT' \
        --security-opt=no-new-privileges \
        $IMAGE_ID
EOF

