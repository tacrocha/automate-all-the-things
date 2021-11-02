#!/usr/bin/env bash

terraform init
terraform apply -auto-approve

# Test application 
APP_URL=$(terraform output -raw application_endpoint_url)
curl $APP_URL
