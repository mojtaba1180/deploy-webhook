#!/bin/bash

update_project() {
    local project_path="$1"
    echo "Updating project in $project_path..."
    cd "$project_path" || exit

    log_file="/home/nfs/salmej/runner/logs/docker_log-$(date +%Y-%m-%d-%H-%M-%S).txt"

    # Execute docker commands separately and log output
    docker compose down | tee -a "$log_file"
    docker compose up --build -d | tee -a "$log_file"

    echo "Project updated."
}

# Array of project paths
declare -a paths=(
    "/home/nfs/salmej/salmej-api/www"
    "/home/nfs/salmej/salmej-dashboard-ui/www"
)

# Loop through each path to check for updates
for path in "${paths[@]}"; do
    echo "Checking for updates in $path..."
    cd "$path" || exit

    log_file="/home/nfs/salmej/runner/logs/git_log-$(date +%Y-%m-%d-%H-%M-%S).txt"

    git_output=$(git pull | tee -a "$log_file")
    
    if [[ "$git_output" != *"Already up to date."* ]]; then
        update_project "$path"
    else
        echo "No updates needed for $path."
    fi
done

echo "All paths checked."
