#!/bin/bash


update_project() {
    echo "Updating project in $1..."
    cd "$1" || exit

    #
    log_file="/home/nfs/salmej/runner/logs/docker_log-$(date +%Y-%m-%d-%H-%M-%S).txt"


    (docker compose down && docker compose up --build -d) | tee -a "$log_file"
    echo "Project updated."
}


declare -a paths=(
    "/home/nfs/salmej/salmej-api/www"
    "/home/nfs/salmej/salmej-dashboard-ui/www"
)


for path in "${paths[@]}"; do
    echo "Checking for updates in $path..."
    cd "$path" || exit

    log_file="/home/nfs/salmej/runner/logs/git_log-$(date +%Y-%m-%d-%H-%M-%S).txt"

    git_output=$(git pull | tee -a "$log_file")
    
    if [[ "$git_output" != *"Already up to date."* ]]; then
        update_project "/home/nfs/salmej"
    else
        echo "No updates needed for $path."
    fi
done

echo "All paths checked."
