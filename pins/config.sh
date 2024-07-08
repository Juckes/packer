#!/bin/bash

APT_REPOSITORIES=(
  "main"
  "restricted"
  "universe"
  "multiverse"
  "ppa:deadsnakes/ppa"
)

COMMON_PACKAGES=(
  "build-essential"
  "ca-certificates"
  "lsb-release"
  "software-properties-common"
)

PYTHON_VERSION="3.7"

# TERRAFORM_VERSIONS=("1.7.3" "1.9.0")

CHECKOV_VERSION="2.2.94"
