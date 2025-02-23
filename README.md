# Hyperspace One-Click Node Setup

This repository provides a simple and automated way to set up a Hyperspace node with a single command. The script will install all necessary dependencies, configure the node, and ensure it runs smoothly.

## Features
- One-click installation
- Automatic dependency setup
- Ensures the node runs correctly

## Installation
To install and run the Hyperspace node, execute the following command in your terminal:

```bash
wget -O Hyperspace.sh https://raw.githubusercontent.com/HarbhagwanDhaliwal/Hyperspace_one_click_node/main/Hyperspace.sh && sed -i 's/\r$//' Hyperspace.sh && chmod +x Hyperspace.sh && ./Hyperspace.sh
```

This command will:
1. Download the `Hyperspace.sh` script from this repository.
2. Convert any Windows-style line endings to Unix format.
3. Make the script executable.
4. Execute the script to install and configure the Hyperspace node.

## Requirements
- A Linux-based operating system (Ubuntu recommended)
- Root or sudo privileges
- A stable internet connection

## Node Management
After installation, you can manage your node with the following commands:

### Start the Node
```bash
systemctl start hyperspace
```

### Stop the Node
```bash
systemctl stop hyperspace
```

### Check Node Status
```bash
systemctl status hyperspace
```

## Troubleshooting
If you encounter any issues, check the logs using:
```bash
journalctl -u hyperspace -f
```

## Contributions
Contributions are welcome! Feel free to open an issue or submit a pull request.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact
For any inquiries or support, feel free to reach out via GitHub issues or connect with the community.

