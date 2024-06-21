#!/bin/bash

# Function to update the project
update_project() {
    local project_path="$1"
    echo "Updating project in $project_path..."
    cd "$project_path" || { echo "Failed to change directory to $project_path"; exit 1; }

    local log_file="/home/nfs/salmej/runner/logs/docker_log-$(date +%Y-%m-%d-%H-%M-%S).txt"

    # Execute docker commands separately and log output
    {
        docker compose down
        docker compose up --build -d
    } | tee -a "$log_file"

    echo "Project updated in $project_path."
}

# Array of project paths
declare -a paths=(
    "/home/nfs/salmej/salmej-api/www"
    "/home/nfs/salmej/salmej-dashboard-ui/www"
)

# Loop through each path to check for updates
for path in "${paths[@]}"; do
    echo "Checking for updates in $path..."
    cd "$path" || { echo "Failed to change directory to $path"; continue; }

    local log_file="/home/nfs/salmej/runner/logs/git_log-$(date +%Y-%m-%d-%H-%M-%S).txt"

    git_output=$(git pull 2>&1 | tee -a "$log_file")
    
    if [[ "$git_output" != *"Already up to date."* ]]; then
        update_project "$path"
    else
        echo "No updates needed for $path."
    fi
done

echo "All paths checked."
