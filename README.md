# V2Ray Server-Side Setup

## Automated V2Ray Server Side Setup

This project aims to automate the installation and configuration of a V2Ray server on a cloud server. V2Ray is a versatile network proxy tool designed to protect your privacy, bypass censorship, and more.

### Prerequisites

Before you begin, ensure you have the following:

- A Linux-based server (e.g., Ubuntu, Debian, CentOS)
- SSH access to the server with administrative privileges
- Basic knowledge of working with a Linux command line

### Installation

1. Clone this repository to your server:
   ```bash
   git clone https://github.com/nimna29/v2ray-server-setup.git
   ```

2. Navigate to the project directory:
   ```bash
   cd v2ray-server-setup
   ```

3. Run the setup script to initiate the installation and configuration process:
   ```bash
   ./setup.sh
   ```

4. Follow the on-screen prompts to customize your V2Ray server settings.

### Configuration
- [x] `v0.3.2` - In this version, the setup script automates the entire configuration process, providing you with a hassle-free setup. 
- [x] It configures your V2Ray server with default settings, ensuring that it's ready to use right away.

   - If you need to customize your V2Ray server, you can do so by editing the `config.json` file located at `/usr/local/etc/v2ray/`.

For users who prefer manual configuration, please note that the setup script no longer guides you through the process.
Instead, you have full control over the configuration by directly editing the `config.json` file.
- [ ] Future updates may include a manual configuration guide for those who prefer a more hands-on approach to setting up V2Ray.
- [x] Please refer to the [V2Ray documentation](https://www.v2fly.org/en_US/v5/config/overview.html) for detailed configuration options when editing `config.json`.

### Usage

Once the setup is complete, your V2Ray server will be running, and you can use it as a secure proxy to protect your online activities.

### Troubleshooting

If you encounter issues during the installation or configuration process, check the project's issue tracker on GitHub for solutions or open a new issue.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

Please note that the use of V2Ray or any other proxy software may be subject to legal restrictions in your region. Ensure you use this software in compliance with all applicable laws and regulations.

😎 Happy automating your V2Ray server setup! ☺️
