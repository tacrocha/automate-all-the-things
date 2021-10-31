# automate-all-the-things

```
podman run -it --rm -v ${PWD}:/aws -v ~/.aws:/root/.aws --entrypoint /bin/sh docker.io/tacrocha/aws-terraform-kubectl

terraform init
terraform apply

terraform destroy
```

