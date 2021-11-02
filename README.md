# automate-all-the-things

This project showcases the usage of Terraform to provision an AWS EKS cluster. It deploys a Go application that exposes an endpoint that returns a JSON with a message and the current timestamp:

```json
{
  "message": "Automate all the things!",
  "timestamp": 1635745431
}
```

## Deploy

Providing the AWS credentials via environment variables:
```shell
export AWS_ACCESS_KEY_ID=<YOUR_AWS_ACCESS_KEY_ID>
export AWS_SECRET_ACCESS_KEY=<YOUR_AWS_SECRET_ACCESS_KEY>
export AWS_DEFAULT_REGION=<YOUR_AWS_DEFAULT_REGION>

cd terraform

docker run -it --rm \
    -v ${PWD}:/aws \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_DEFAULT_REGION \
    --entrypoint /bin/sh \
    docker.io/tacrocha/aws-terraform-kubectl \
    deploy.sh
```

If you have previously configured the AWS cli on your machine and your credentials are at `~/.aws`, or `/root/.aws` if you run Docker with sudo:

```shell
cd terraform

docker run -it --rm \
    -v ${PWD}:/aws \
    -v ~/.aws:/root/.aws \
    --entrypoint /bin/sh \
    docker.io/tacrocha/aws-terraform-kubectl \
    deploy.sh
```

## Access the application
Once the deployment is complete, you'll find the `application_endpoint_url` as Terraform output. Copy and paste on your browser to try the application.

## Destroy

Providing the AWS credentials via environment variables:

```shell
export AWS_ACCESS_KEY_ID=<YOUR_AWS_ACCESS_KEY_ID>
export AWS_SECRET_ACCESS_KEY=<YOUR_AWS_SECRET_ACCESS_KEY>
export AWS_DEFAULT_REGION=<YOUR_AWS_DEFAULT_REGION>

cd terraform

docker run -it --rm \
    -v ${PWD}:/aws \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_DEFAULT_REGION \
    --entrypoint /bin/sh \
    docker.io/tacrocha/aws-terraform-kubectl \
    destroy.sh
```

If you have previously configured the AWS cli on your machine and your credentials are at `~/.aws`, or `/root/.aws` if you run Docker with sudo:

```shell
cd terraform

docker run -it --rm \
    -v ${PWD}:/aws \
    -v ~/.aws:/root/.aws \
    --entrypoint /bin/sh \
    docker.io/tacrocha/aws-terraform-kubectl \
    destroy.sh
```
## TODO, shortcomings and notes
1) The automated test at the end of the terraform deployment did not work using the `null_resource` with a curl command. It would run before the Kubernetes LoadBalancer service was created and fail. **UPDATE:** Used `terraform output -raw` to pass the application URL to curl inside the `deploy.sh` script.
1) I had planned to use more the kanban board of my Github repo, but ended up not using it that much.
1) The commands would be simpler if there was a script that took `deploy|destroy` as parameter and also verified if the user had the `~/.aws` folder of if the AWS credentials were set by environment variables, generating the docker run command accordingly.
1) The project assumes Linux or MacOS, no Windows.
1) The VPC resource deserved more attention in order to include only the necessary subnets for a minimal EKS, but I left what I found in my references and was working, and went on to tackle the other requirements.