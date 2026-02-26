set -e
echo 'Build docker image for udemy test flask app'
source env.sh
echo $IMAGE_ID
docker build -f Dockerfile -t $IMAGE_ID --no-cache .
