# automate-all-the-things

// TODO: Add AWS cli authentication instructions and user guide

```
cd terraform
podman run -it --rm -v ${PWD}:/aws -v ~/.aws:/root/.aws --entrypoint /bin/sh docker.io/tacrocha/aws-terraform-kubectl

terraform init
terraform apply

terraform destroy
```
