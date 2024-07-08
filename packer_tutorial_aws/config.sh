#!/bin/bash

APT_REPOSITORIES=(
  "main"
  "restricted"
  "universe"
  "multiverse"
  # "ppa:deadsnakes/ppa" # This one is definitely needed for python distils
)

COMMON_PACKAGES=(
  # "ca-certificates"
  # "curl"
  # "gnupg"
  # "jq"
  # "lsb-release"
  # "software-properties-common"
  # "unzip"
  # "zip"

  "build-essential" # Used by Docker
  "ca-certificates" # secure connections
  # "curl" installed already
  # "gnupg" v 2 is installed
  # "jq" installed already
  # "libasound2"
  # "libgbm-dev"
  # "libgconf-2-4"
  # "libgtk2.0-0"
  # "libgtk-3-0"
  # "libnotify-dev"
  # "libnss3"
  # "libxss1"
  # "libxtst6"
  "lsb-release"
  "software-properties-common"
  # "unzip" installed already
  # "xauth"
  # "xvfb"
  # "zip" installed already
)

# PYTHON_VERSION="3.9"

# TERRAFORM_VERSIONS=("1.7.3" "1.9.0")
