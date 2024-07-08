#!/bin/bash

APT_REPOSITORIES=(
  "main"
  "restricted"
  "universe"
  "multiverse"
  "ppa:deadsnakes/ppa"
)

COMMON_PACKAGES=(
  # "build-essential"
  # "ca-certificates" newest version included already
  # "lsb-release" newest version already included
  # "software-properties-common" newest version already included - NOT on minimal though
  # jq
  # libasound2 newest version already included - NOT on minimal though
  # libgbm-dev NOT on either version
  # libgconf-2-4 NOT on either version
  # libgtk2.0-0 NOT on either version
  # libgtk-3-0 NOT on either version
  # libNOTify-dev NOT on either version
  # libnss3 newest version already included - NOT on minimal though
  # libxss1 NOT on either version
  # libxtst6 NOT on either version
#   unzip NOT on either version
#   xauth newest version already included - NOT on minimal though
#   xvfb NOT on either version
#   zip newest version already included
#
  "build-essential"
  "jq"
  "libgbm-dev"
  "libgconf-2-4"
  "libgtk2.0-0"
  "libgtk-3-0"
  "libnotify-dev"
  "libxss1"
  "libxtst6"
  "unzip"
  "xvfb"
  "python3-pip"
)




# PYTHON_VERSION="3.7"

TERRAFORM_VERSIONS=("1.7.3" "1.9.0")

CHECKOV_VERSION="3.2.171"
