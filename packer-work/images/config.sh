#!/bin/bash
APT_REPOSITORIES=(
  "main"
  "restricted"
  "universe"
  "multiverse"
  "ppa:git-core/ppa"
  "ppa:deadsnakes/ppa"
)

COMMON_PACKAGES=(
  "build-essential"
  "jq"
  "unzip"
  "zip"
  "xvfb"
  "python3-pip"
)

DOCKER_COMPOSE_VERSION="1.29.2"

TFENV_VERSION="v3.0.0"

TERRAFORM_VERSIONS=("1.7.3" "1.9.1")
DEFAULT_TERRAFORM_VERSION="1.9.1"

TERRAGRUNT_VERSION="0.55.1"

CHECKOV_VERSION="2.2.94"

NODE_VERSIONS=("20" "18")
DEFAULT_NODE_VERSION="18"
