#!/bin/bash

# Function to parse AWS profiles from ~/.aws/config
get_aws_profiles() {
  if [[ ! -f ~/.aws/config ]]; then
    echo "Error: AWS config file not found at ~/.aws/config" >&2
    return 1
  fi
  grep "^\[profile" ~/.aws/config | sed -e 's/\[profile //g' -e 's/\]//g'
}

# Function to get a list of ECS clusters
get_clusters() {
  local profile="$1"
  local auth_method="$2"
  
  if [[ "$auth_method" == "aws-vault" ]]; then
    aws-vault exec "$profile" -- aws ecs list-clusters | jq -r '.clusterArns[]'
  elif [[ "$auth_method" == "granted" ]]; then
    g assume "$profile" -- aws ecs list-clusters | jq -r '.clusterArns[]'
  else
    echo "Error: Invalid auth method" >&2
    return 1
  fi
}

# Function to get a list of ECS tasks for a service
get_tasks() {
  local profile="$1"
  local auth_method="$2"
  local cluster="$3"
  local service="$4"

  if [[ "$auth_method" == "aws-vault" ]]; then
    aws-vault exec "$profile" -- aws ecs list-tasks --cluster "$cluster" --service-name "$service" | jq -r '.taskArns[]'
  elif [[ "$auth_method" == "granted" ]]; then
    g assume "$profile" -- aws ecs list-tasks --cluster "$cluster" --service-name "$service" | jq -r '.taskArns[]'
  else
    echo "Error: Invalid auth method" >&2
    return 1
  fi
}

# Function to get the EC2 instance ID for a selected task
get_instance_id() {
  local profile="$1"
  local auth_method="$2"
  local cluster="$3"
  local task_arn="$4"

  # First, get the container instance ARN from the task ARN
  local container_instance_arn
  if [[ "$auth_method" == "aws-vault" ]]; then
    container_instance_arn=$(aws-vault exec "$profile" -- aws ecs describe-tasks --cluster "$cluster" --tasks "$task_arn" | jq -r '.tasks[0].containerInstanceArn')
    # Then, get the EC2 instance ID from the container instance ARN
    aws-vault exec "$profile" -- aws ecs describe-container-instances --cluster "$cluster" --container-instances "$container_instance_arn" | jq -r '.containerInstances[0].ec2InstanceId'
  elif [[ "$auth_method" == "granted" ]]; then
    container_instance_arn=$(g assume "$profile" -- aws ecs describe-tasks --cluster "$cluster" --tasks "$task_arn" | jq -r '.tasks[0].containerInstanceArn')
    g assume "$profile" -- aws ecs describe-container-instances --cluster "$cluster" --container-instances "$container_instance_arn" | jq -r '.containerInstances[0].ec2InstanceId'
  else
    echo "Error: Invalid auth method" >&2
    return 1
  fi
}
