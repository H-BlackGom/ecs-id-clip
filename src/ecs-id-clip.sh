#!/bin/bash

# Source the utility functions
# shellcheck source=src/lib/utils.sh
source "$(dirname "$0")"/lib/utils.sh"
# shellcheck source=src/lib/aws_helpers.sh
source "$(dirname "$0")"/lib/aws_helpers.sh"
# shellcheck source=src/lib/fzf_helpers.sh
source "$(dirname "$0")"/lib/fzf_helpers.sh"

# Check for required tools
check_prerequisites "aws" "jq" "fzf"

main() {
  # Prompt for authentication method
  auth_methods="aws-vault\ngranted"
  auth_method=$(select_from_list "$auth_methods")

  if [[ -z "$auth_method" ]]; then
    echo "No authentication method selected. Exiting." >&2
    exit 1
  fi

  # Get and select AWS profile
  profiles=$(get_aws_profiles)
  if [[ -z "$profiles" ]]; then
    exit 1
  fi
  selected_profile=$(select_from_list "$profiles")

  if [[ -z "$selected_profile" ]]; then
    echo "No profile selected. Exiting." >&2
    exit 1
  fi

  echo "Using profile: $selected_profile"

  # Get and select ECS cluster
  clusters=$(get_clusters "$selected_profile" "$auth_method")
  if [[ -z "$clusters" ]]; then
    echo "No ECS clusters found in this region." >&2
    exit 1
  fi
  selected_cluster=$(select_from_list "$clusters")

  if [[ -z "$selected_cluster" ]]; then
    echo "No cluster selected. Exiting." >&2
    exit 1
  fi

  echo "Using cluster: $selected_cluster"

  # Get service name from user
  echo -n "Enter the ECS service name: "
  read -r service_name

  if [[ -z "$service_name" ]]; then
    echo "No service name entered. Exiting." >&2
    exit 1
  fi

  # Get and select ECS task
  tasks=$(get_tasks "$selected_profile" "$auth_method" "$selected_cluster" "$service_name")
  if [[ -z "$tasks" ]]; then
    echo "No running EC2 tasks found for service '$service_name'." >&2
    exit 1
  fi
  selected_task=$(select_from_list "$tasks")

  if [[ -z "$selected_task" ]]; then
    echo "No task selected. Exiting." >&2
    exit 1
  fi

  # Get the EC2 instance ID
  instance_id=$(get_instance_id "$selected_profile" "$auth_method" "$selected_cluster" "$selected_task")
  if [[ -z "$instance_id" ]]; then
    echo "Could not find the EC2 instance ID for the selected task." >&2
    exit 1
  fi

  # Copy to clipboard and print success message
  copy_to_clipboard "$instance_id"
  echo "Success! EC2 Instance ID '$instance_id' has been copied to your clipboard."
}

main "$@"