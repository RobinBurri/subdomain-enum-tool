#!/bin/bash

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo "Docker does not seem to be running, start it first and rerun this script"
        exit 1
    fi
}

# Function to create necessary directories
create_directories() {
    echo "Checking and creating necessary directories..."
    if [ ! -d "output" ]; then
        echo "Creating output directory..."
        mkdir output
    fi
    if [ ! -d "scripts" ]; then
        echo "Creating scripts directory..."
        mkdir scripts
    fi
}

# Function to check if the image exists
image_exists() {
    docker image inspect subdomain-enum-tool_recon-tools >/dev/null 2>&1
}

# Function to start Docker Compose
start_docker_compose() {
    if image_exists; then
        echo "Docker image already exists. Starting container..."
        docker compose up -d
    else
        echo "Building Docker image..."
        docker compose build
        echo "Starting Docker Compose..."
        docker compose up -d
    fi
    if [ $? -ne 0 ]; then
        echo "Failed to start Docker Compose"
        exit 1
    fi
}

# Function to wait for container to be ready
wait_for_container() {
    echo "Waiting for container to be ready..."
    while ! docker compose exec recon-tools echo "Container is up" >/dev/null 2>&1; do
        sleep 1
    done
}

# Function to enter the container
enter_container() {
    echo "Entering the container..."
    docker compose exec recon-tools bash
}

# Main execution
check_docker
create_directories
start_docker_compose
wait_for_container
enter_container