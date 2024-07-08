# notes

disable the image in aws so you do not get billed
ami images and also snapshots

## Are these packages all needed?

Removed some packages that may not be required, such as:

- **libasound2**
  - *libasound2* is a library that provides the ALSA (Advanced Linux Sound Architecture) API. It is part of the ALSA sound system, which is used in Linux for managing sound cards and audio devices. libasound2 allows applications to interface with the ALSA sound system to perform tasks such as audio playback, recording, and mixing.
- **libgbm-dev**
  - libgbm-dev is a development package that provides the Mesa Graphics Buffer Manager (GBM) library and the necessary headers for developing applications that use GBM. GBM is a library used in graphics programming for managing graphics buffers, which are used as render targets or scanout buffers.
- **libgconf-2-4**
  - libgconf-2-4 is a library that is part of the GConf configuration system, which is used for managing application settings in GNOME-based systems. It provides APIs to read, write, and manage configuration settings stored in a centralized configuration database.
  - Including libgconf-2-4 in your installation script is necessary if your application or any dependencies require GConf for configuration management.
- **libgtk2.0-0**
  - libgtk2.0-0 is a package that provides the GTK+ 2.0 library, which is a multi-platform toolkit for creating graphical user interfaces (GUIs). GTK+ (GIMP Toolkit) is widely used for developing applications that run on various operating systems, including Linux, Windows, and macOS.
  - Including libgtk2.0-0 in your installation script is necessary if your application or any dependencies require GTK+ 2.0 for GUI development.
- **libgtk-3-0** - Is an upgrade over previous package, so not sure why both are needed unless a dependency on both for something?
- **libnotify-dev**
  - libnotify-dev is a development package that provides the necessary files to build applications using libnotify, a library for sending desktop notifications on Linux systems. These notifications are small pop-up messages that provide feedback or information to the user.
  - Including libnotify-dev in your installation script is necessary if your application needs to send desktop notifications. This package is particularly useful for applications that require real-time user feedback or alerts. If your project involves creating a GUI application that will notify users of various events, libnotify-dev is an essential package.
- **libnss3**
  - libnss3 is a development library in Linux that provides functions and utilities for the Name Service Switch (NSS) framework.
  - If your pipeline builds or deploys applications that interact with custom NSS modules for specialized functionality (e.g., authentication against a non-standard backend), you might need libnss3 to provide the necessary development environment for those applications.
- **libxss1**
  - libxss1 is a library that provides an interface for applications to interact with the X Window System Screen Saver extension. The Screen Saver extension allows applications to register themselves as screen savers and integrate with the running session.
  - your pipeline involves running a custom screen saver application, libxss1 might be required for that application to function properly.
- **libxtst6**
  - libxtst6 is a library that provides an interface for applications to interact with the X Window System extension for testing and manipulating the X server.
  - Unless you have a specific reason to believe your pipeline needs libxtst6 for UI testing, it's safe to remove it from the script.

## Docker Dependencies

Docker's essential dependencies typically include:

- containerd: An industry-standard container runtime.
- runc: A CLI tool for spawning and running containers according to the OCI specification.
- libseccomp: A library providing an interface to the Linux kernel's seccomp filter, used for sandboxing.
- aufs-tools or overlay2: Storage drivers for managing the container file system layers.
- iproute2: A collection of utilities for controlling networking in Linux.
- cgroup-related libraries: For managing control groups to limit and isolate the resource usage of processes.
- netfilter-related packages: For configuring and managing firewall rules.

## Gemini ai

Potentially Unnecessary Packages:

General Development Tools:
  build-essential (for compiling C/C++ code)
  libgbm-dev (for statistical functions)
  libgconf-2-4 (for GNOME configuration)
  libgtk2.0-0, libgtk-3-0 (for graphical user interface toolkits)
  libnotify-dev (for desktop notifications)
  libxss1, libxtst6 (for X Window System extensions)

## apt repos

- Main: This is the official Ubuntu repository containing essential packages for core system functionality. It's almost always needed for any Linux system.
- Restricted: This repository contains software that may have legal or licensing restrictions. It's not essential for basic functionality and might be excluded depending on your pipeline needs and legal compliance considerations.
- Universe: This repository contains free and open-source software (FOSS) that may not be officially supported by Ubuntu. It's a good source for additional tools and utilities, but some pipelines might not require anything from here.
- Multiverse: This repository contains software that may not be entirely free or open-source, or might have dependencies on restricted packages. Similar to universe, it's optional and depends on your pipeline's specific needs.

add_apt_repository ppa:git-core/ppa - this offers the latest git features but, main will have everything we need

ppa:deadsnakes/ppa - this PPA provides newer versions of Python than what's available in the default repositories. It's only necessary if your pipelines specifically require a Python version not offered in the main repository.

Git is already installed on the system so do we need to reinstall it again?

Use `sudo apt-cache search <package_name>` to search main for the packages that are required

- `install_packages git git-lfs git-ftp`
  - lfs do we have large datasets run in the agents?
  - can we get rid of the whole line as git is already installed in ubuntu 20.04

`apt` instead of `apt-get` is better practice and more modern

DEBIAN_FRONTEND=noninteractive
Automated tasks:
If your script automates tasks like installing packages, setting DEBIAN_FRONTEND=noninteractive ensures the script runs without user intervention and avoids unexpected prompts.
Repeatability: It makes the script's behavior more predictable and repeatable across environments where user interaction might differ.

## Issues

scp mj@20.51.197.51:/home/mj/packs.txt ~/Downloads/

## Put up a script
