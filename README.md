# ECS Instance ID Clipper

This guide explains how to install and use the `ecs-id-clip` tool.

## Prerequisites

You must have the following CLI tools installed and available in your `PATH`:

1.  **[aws-cli](https://aws.amazon.com/cli/)**: The AWS Command Line Interface (v2 recommended).
2.  **[jq](https://stedolan.github.io/jq/)**: A command-line JSON processor.
3.  **[fzf](https://github.com/junegunn/fzf)**: A command-line fuzzy finder.
4.  **[aws-vault](https://github.com/99designs/aws-vault)** or **[granted](https://www.granted.dev/)**: For handling AWS credentials.

Your AWS credentials should be configured in `~/.aws/config`.

## Installation

1.  Clone this repository:
    ```bash
    git clone <repo_url>
    cd <repo_directory>
    ```
2.  Make the main script executable:
    ```bash
    chmod +x src/ecs-id-clip.sh
    ```
3.  (Optional) Create a symbolic link to a directory in your `PATH` for easy access:
    ```bash
    sudo ln -s "$(pwd)/src/ecs-id-clip.sh" /usr/local/bin/ecs-id-clip
    ```

## Usage

Simply run the command from the root of the project:

```bash
./src/ecs-id-clip.sh
```

This will launch the interactive workflow:

1.  Select your AWS profile.
2.  Select the ECS cluster.
3.  Type the name of the ECS service.
4.  Select the running task.

The EC2 instance ID for the selected task will be automatically copied to your clipboard.