set -e
echo 'Store docker image for for udemy security python app'
source env.sh
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URI

docker push $IMAGE_ID
