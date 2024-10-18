#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Setting up the project structure..."

# Create main directories
mkdir -p audio compare services/mlx_whisper services/lightning_whisper services/whisper_turbo services/plotter outputs

# Create Dockerfiles and transcription scripts for each service

## mlx_whisper
cat > services/mlx_whisper/Dockerfile <<EOL
# services/mlx_whisper/Dockerfile
FROM python:3.10-slim

# Install system dependencies including ffmpeg
RUN apt-get update && apt-get install -y git ffmpeg && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Install mlx-whisper
RUN pip install --no-cache-dir mlx-whisper

# Copy transcription script
COPY transcribe.py .

# Define entrypoint
ENTRYPOINT ["python", "transcribe.py"]
EOL

cat > services/mlx_whisper/transcribe.py <<EOL
# services/mlx_whisper/transcribe.py
import mlx_whisper

def transcribe():
    audio_path = "/data/podcast.mp3"
    output_path = "/outputs/mlx_whisper_output.txt"
    model_repo = "mlx-community/whisper-base.en-mlx-q4"

    print("Starting transcription with mlx-whisper...")
    text = mlx_whisper.transcribe(audio_path, path_or_hf_repo=model_repo)

    with open(output_path, "w") as f:
        f.write(text)
    print(f"Transcription completed. Output saved to {output_path}")

if __name__ == "__main__":
    transcribe()
EOL

## lightning_whisper
cat > services/lightning_whisper/Dockerfile <<EOL
# services/lightning_whisper/Dockerfile
FROM python:3.10-slim

# Install system dependencies including ffmpeg
RUN apt-get update && apt-get install -y git ffmpeg && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Install lightning-whisper-mlx
RUN pip install --no-cache-dir lightning-whisper-mlx

# Copy transcription script
COPY transcribe.py .

# Define entrypoint
ENTRYPOINT ["python", "transcribe.py"]
EOL

cat > services/lightning_whisper/transcribe.py <<EOL
# services/lightning_whisper/transcribe.py
from lightning_whisper_mlx import LightningWhisperMLX

def transcribe():
    audio_path = "/data/podcast.mp3"
    output_path = "/outputs/lightning_whisper_output.txt"

    print("Starting transcription with lightning-whisper-mlx...")
    whisper = LightningWhisperMLX(model="tiny", batch_size=12, quant=None)
    result = whisper.transcribe(audio_path)

    with open(output_path, "w") as f:
        f.write(result['text'])
    print(f"Transcription completed. Output saved to {output_path}")

if __name__ == "__main__":
    transcribe()
EOL

## whisper_turbo
cat > services/whisper_turbo/Dockerfile <<EOL
# services/whisper_turbo/Dockerfile
FROM python:3.10-slim

# Install system dependencies including ffmpeg
RUN apt-get update && apt-get install -y git ffmpeg && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Clone the repository
RUN git clone https://github.com/JosefAlbers/whisper-turbo-mlx.git

# Navigate to the repository directory
WORKDIR /app/whisper-turbo-mlx

# Install the package in editable mode
RUN pip install --no-cache-dir -e .

# Copy transcription script
COPY transcribe.py .

# Define entrypoint
ENTRYPOINT ["python", "transcribe.py"]
EOL

cat > services/whisper_turbo/transcribe.py <<EOL
# services/whisper_turbo/transcribe.py
from whisper_turbo import transcribe

def transcribe_audio():
    audio_path = "/data/podcast.mp3"
    output_path = "/outputs/whisper_turbo_output.txt"

    print("Starting transcription with whisper-turbo-mlx...")
    text = transcribe(audio_path, any_lang=True)

    with open(output_path, "w") as f:
        f.write(text)
    print(f"Transcription completed. Output saved to {output_path}")

if __name__ == "__main__":
    transcribe_audio()
EOL

## plotter
cat > services/plotter/Dockerfile <<EOL
# services/plotter/Dockerfile
FROM python:3.10-slim

# Install system dependencies including ffmpeg (if necessary)
RUN apt-get update && apt-get install -y git ffmpeg && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Install required Python packages
RUN pip install --no-cache-dir matplotlib pandas

# Install jiwer for advanced comparison (optional)
RUN pip install --no-cache-dir jiwer

# Copy plotting script
COPY plot.py .

# Define entrypoint
ENTRYPOINT ["python", "plot.py"]
EOL

cat > services/plotter/plot.py <<EOL
# services/plotter/plot.py
import os
import time
import matplotlib.pyplot as plt
from jiwer import wer  # Optional, for advanced comparison

def read_transcription(file_path):
    with open(file_path, 'r') as f:
        return f.read()

def wait_for_files(file_paths, timeout=300, check_interval=5):
    """
    Wait until all files exist or timeout is reached.
    """
    start_time = time.time()
    while True:
        if all(os.path.exists(fp) for fp in file_paths):
            break
        if time.time() - start_time > timeout:
            raise TimeoutError("Timeout waiting for transcription files.")
        time.sleep(check_interval)

def plot_comparison(transcriptions, output_dir):
    labels = list(transcriptions.keys())
    values = list(transcriptions.values())

    plt.figure(figsize=(10, 6))
    bars = plt.bar(labels, values, color=['blue', 'green', 'orange'])

    # Adding value labels on top of each bar
    for bar in bars:
        yval = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2.0, yval + 5, yval, ha='center', va='bottom')

    plt.ylabel('Transcription Length (characters)')
    plt.title('Comparison of Transcription Lengths Across MLX Whisper Packages')
    plt.ylim(0, max(values) * 1.1)
    plt.savefig(os.path.join(output_dir, "transcription_length_comparison.png"))
    plt.close()
    print(f"Plot saved to {os.path.join(output_dir, 'transcription_length_comparison.png')}")

def plot_wer_comparison(transcriptions, ground_truth, output_dir):
    wer_scores = {}
    for key, text in transcriptions.items():
        wer_score = wer(ground_truth, text)
        wer_scores[key] = wer_score

    labels = list(wer_scores.keys())
    values = list(wer_scores.values())

    plt.figure(figsize=(10, 6))
    bars = plt.bar(labels, values, color=['blue', 'green', 'orange'])

    # Adding value labels on top of each bar
    for bar in bars:
        yval = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2.0, yval + 0.01, f"{yval:.2f}", ha='center', va='bottom')

    plt.ylabel('Word Error Rate (WER)')
    plt.title('Comparison of Transcription Accuracy Across MLX Whisper Packages')
    plt.ylim(0, max(values) * 1.1)
    plt.savefig(os.path.join(output_dir, "wer_comparison.png"))
    plt.close()
    print(f"WER Plot saved to {os.path.join(output_dir, 'wer_comparison.png')}")

def main():
    output_dir = "/outputs"
    transcription_files = [
        os.path.join("/outputs", "mlx_whisper_output.txt"),
        os.path.join("/outputs", "lightning_whisper_output.txt"),
        os.path.join("/outputs", "whisper_turbo_output.txt")
    ]

    print("Plotter is waiting for transcription files...")
    wait_for_files(transcription_files)
    print("All transcription files detected. Proceeding to plot.")

    # Read transcriptions
    transcriptions = {
        'mlx_whisper': read_transcription(transcription_files[0]),
        'lightning_whisper-mlx': read_transcription(transcription_files[1]),
        'whisper_turbo-mlx': read_transcription(transcription_files[2])
    }

    # Plot transcription lengths
    transcription_lengths = {k: len(v) for k, v in transcriptions.items()}
    plot_comparison(transcription_lengths, output_dir)

    # Optional: Advanced comparison using WER
    ground_truth_path = "/compare/ground_truth.txt"
    if os.path.exists(ground_truth_path):
        ground_truth = read_transcription(ground_truth_path)
        plot_wer_comparison(transcriptions, ground_truth, output_dir)
    else:
        print("Ground truth file not found. Skipping WER comparison.")

if __name__ == "__main__":
    main()
EOL

# Create docker-compose.yml
cat > docker-compose.yml <<EOL
# docker-compose.yml
version: '3.8'

services:
  mlx_whisper:
    build:
      context: ./services/mlx_whisper
      dockerfile: Dockerfile
    volumes:
      - ./audio:/data
      - ./outputs:/outputs
    container_name: mlx_whisper_container

  lightning_whisper:
    build:
      context: ./services/lightning_whisper
      dockerfile: Dockerfile
    volumes:
      - ./audio:/data
      - ./outputs:/outputs
    container_name: lightning_whisper_container

  whisper_turbo:
    build:
      context: ./services/whisper_turbo
      dockerfile: Dockerfile
    volumes:
      - ./audio:/data
      - ./outputs:/outputs
    container_name: whisper_turbo_container

  plotter:
    build:
      context: ./services/plotter
      dockerfile: Dockerfile
    volumes:
      - ./outputs:/outputs
      - ./audio:/data
      - ./compare:/compare
    depends_on:
      - mlx_whisper
      - lightning_whisper
      - whisper_turbo
    container_name: plotter_container
EOL

# Create placeholder audio file
touch audio/podcast.mp3
echo "Replace this file with your actual audio file for transcription." > audio/podcast.mp3

# Create placeholder ground_truth.txt (optional)
touch compare/ground_truth.txt
echo "Replace this file with your ground truth transcription (if available)." > compare/ground_truth.txt

# Create a basic README.md
cat > README.md <<EOL
# MLX Whisper Comparison

A Docker Compose-based solution to compare three different MLX Whisper packages for audio transcription and visualize the results.

## **Overview**

This repository provides a containerized environment to transcribe an audio file using three different MLX Whisper packages, collect their transcription outputs, and generate comparison plots. The setup ensures isolation of dependencies using Docker, making it easy to reproduce and compare the performance of each package.

## **Directory Structure**

\`\`\`
mlx_whisper_comparison/
├── audio/
│   └── podcast.mp3
├── compare/
│   └── ground_truth.txt  # (Optional for advanced comparison)
├── docker-compose.yml
├── services/
│   ├── lightning_whisper/
│   │   ├── Dockerfile
│   │   └── transcribe.py
│   ├── mlx_whisper/
│   │   ├── Dockerfile
│   │   └── transcribe.py
│   ├── plotter/
│   │   ├── Dockerfile
│   │   └── plot.py
│   └── whisper_turbo/
│       ├── Dockerfile
│       └── transcribe.py
└── outputs/
\`\`\`

- **\`audio/\`**: Contains the audio file to be transcribed (\`podcast.mp3\`).
- **\`compare/\`**: (Optional) Contains \`ground_truth.txt\` for advanced comparison using Word Error Rate (WER).
- **\`services/\`**: Contains subdirectories for each transcription service and the plotting service, each with their own \`Dockerfile\` and scripts.
- **\`outputs/\`**: Shared volume where transcription outputs and plots will be stored.
- **\`docker-compose.yml\`**: Defines all services and their configurations.

## **Setup and Usage**

### **Prerequisites**

- **Docker** and **Docker Compose** installed on your machine.
- An audio file named \`podcast.mp3\` placed inside the \`audio/\` directory.
- (Optional) A ground truth transcription named \`ground_truth.txt\` placed inside the \`compare/\` directory for advanced comparison.

### **1. Clone the Repository**

```bash
git clone hhttps://github.com/CodeWithBehnam/mlx-whisper-comparison
cd mlx-whisper-comparison
