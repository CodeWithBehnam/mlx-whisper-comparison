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
git clone https://github.com/your_username/mlx-whisper-comparison.git
cd mlx-whisper-comparison