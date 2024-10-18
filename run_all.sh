#!/bin/bash

set -e

echo "Building Docker images..."
docker-compose build

echo "Starting transcription with mlx-whisper..."
docker-compose run --rm mlx_whisper

echo "Starting transcription with lightning-whisper-mlx..."
docker-compose run --rm lightning_whisper

echo "Starting transcription with whisper-turbo-mlx..."
docker-compose run --rm whisper_turbo

echo "Generating comparison plots..."
docker-compose run --rm plotter

echo "All tasks completed successfully."
