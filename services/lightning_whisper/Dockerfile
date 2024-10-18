# services/lightning_whisper/Dockerfile
FROM python:3.12-slim

# Install system dependencies including ffmpeg
RUN apt-get update && apt-get install -y git ffmpeg && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Install lightning-whisper-mlx
RUN pip install --no-cache-dir lightning-whisper-mlx mlx

# Copy transcription script
COPY transcribe.py .

# Define entrypoint
ENTRYPOINT ["python", "transcribe.py"]
