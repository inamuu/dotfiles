terraform {
  required_version = ">= 1.14.3"
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.3" 
    }
  }
}

