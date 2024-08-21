# Dev Container SSH Setup

This project automates the creation and configuration of a development environment within containers using Incus (LXD) and Cloud-Init. The environment is designed to facilitate seamless SSH access between containers, enabling a smooth workflow for developers working with multiple containers.

## Features

- **Automated Container Creation**: Uses Incus (LXD) to create Ubuntu-based containers.
- **Pre-configured Development Tools**: The `dev-container` includes essential tools like Neovim, GCC, Git, and OpenSSH server.
- **Shared Disk Access**: Containers have shared access to a specified directory on the host system.
- **Automatic SSH Key Distribution**: The SSH keys generated within the `dev-container` are automatically distributed to other containers, enabling passwordless SSH access.
- **User Management**: Optionally includes a user setup for `decoder` with sudo privileges.
- **Firewall Configuration**: UFW is enabled to secure SSH access.

## Usage

1. **Create and Configure the Development Container**:
   ```sh
   just create_nvim_container
   ```
   This command will create a new container named `dev-container`, configure it with the necessary tools and SSH keys, and set up shared disk access.

2. **Copy SSH Keys to Other Containers**:
   ```sh
   just copy_keys dev-container target-container
   ```
   This command will copy the SSH keys from the `dev-container` to another container, allowing SSH access between them.

3. **Start Neovim in the Dev Container**:
   ```sh
   just start_nvim
   ```
   This will open Neovim in the `dev-container` for development tasks.

## Configuration

- **SSH and Firewall Settings**: The project configures the SSH daemon and firewall (UFW) on each container, securing access and ensuring that only SSH connections are allowed.
- **User and Permissions**: The containers can be configured to include a `decoder` user with SSH access. This setup is optional and can be customized as needed.

## Requirements

- **Incus (LXD)**: Ensure that Incus is installed and configured on your host system.
- **Just**: The automation is powered by `just`, a handy command runner.

## License

This project is licensed under the MIT License.

