terraform {

required_providers {
  aws = {
    source = "hashicorp/aws"
    version = "3.63.0"
  }

  kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.6.1"
  }
}

  required_version = ">= 1.0.10"
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {

}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"

    cidr_blocks = [
      "10.0.0.0/8"
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_mgmt"
  vpc_id = module.vpc.vpc_id

ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"

  cidr_blocks = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.10.0"

  name = "tacio-vpc"
  cidr = "10.0.0.0/16"
  azs = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }

}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.22.0"
  cluster_name = var.cluster_name
  cluster_version = "1.21"
  subnets = module.vpc.private_subnets
  cluster_create_timeout = "1h"
  cluster_endpoint_private_access = true
  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name = "worker-group-1"
      instance_type = "t2.small"
      asg_desired_capacity = 1
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    }
  ]
  
  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_deployment" "automate-all-the-things" {

  metadata {
    name = "automate-all-the-things"
    labels = {
      "app.kubernetes.io/name" =  "automate-all-the-things"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        "app.kubernetes.io/name" =  "automate-all-the-things"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" =  "automate-all-the-things"
        }
      }
    
      spec {
        container {
          image = "docker.io/tacrocha/automate-all-the-things:latest"
          name = "goapp"
        
          resources {
            limits = {
              cpu = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "automate-all-the-things" {
  metadata {
    name = "terraform-example"
  }
  spec {
    selector = {
      "app.kubernetes.io/name" =  "automate-all-the-things"
    }
    port {
      port = 80
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}

locals {
  lb_hostname = kubernetes_service.automate-all-the-things.status.0.load_balancer.0.ingress.0.hostname
}

# resource "null_resource" "test-app" {
#   triggers = {
#     always_run = "${timestamp()}"
#   }
#   provisioner "local-exec" {
#     command = "curl -s ${local.lb_hostname}"
#   }
#   depends_on = [
#     kubernetes_service.automate-all-the-things,
#   ]
# }
