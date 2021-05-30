terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = "~> 3.40.0"
  }

}
provider "aws" {
  region = "ap-southeast-2"
}

