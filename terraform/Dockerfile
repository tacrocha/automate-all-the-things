# syntax=docker/dockerfile:1

FROM amazon/aws-cli:2.3.2

RUN yum install -y unzip git

# Install Terraform
RUN curl -s -o /tmp/terraform.zip -OL https://releases.hashicorp.com/terraform/1.0.10/terraform_1.0.10_linux_amd64.zip && \
    unzip /tmp/terraform.zip && \
    chmod +x terraform && \
    mv terraform /usr/local/bin/

RUN curl -s -o /tmp/kubectl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x /tmp/kubectl && \
    mv /tmp/kubectl /usr/local/bin/
