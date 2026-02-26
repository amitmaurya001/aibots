# README #

This README would normally document whatever steps are necessary to get your application up and running.

### How do I get set up? ###

```
Install aws-cli - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
Configure aws profile e.g - https://sergiiblog.com/devops-basics-how-to-work-with-multiple-aws-accounts-using-aws-cli/
export AWS_PROFILE=your_profile_name

Test connection: aws sts get-caller-identity
```

### How to work with terraform? ###
```
terraform apply -var-file ../env.tfvars
terraform destroy -var-file ../env.tfvars

Sequence of running modules:
1. pre-init - enough to run once to create s3 bucket and dynamoDB table for keeping  terrafrom state and locks
2. network
3. sns
4. alb
5. ec2-flas4k-app
6. cloudwatch

```

## How to work with ECR? ###
```
docker login -u AWS -p $(aws ecr get-login-password --region ${REGION}) ${ACCOUND_ID}.dkr.ecr.${REGION}.amazonaws.com
docker build . -t ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:latest
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:latest
```

## SSH config example ###
Host udemy-flask
    HostName x.x.x.x
    User ubuntu
    IdentitiesOnly yes
    IdentityFile {put_path_to_yours_ssh_key_here}