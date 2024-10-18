# services/mlx_whisper/Dockerfile
FROM python:3.12-slim

# Install system dependencies including ffmpeg
RUN apt-get update && apt-get install -y git ffmpeg && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

RUN pip install -U pip

# Install mlx-whisper
RUN pip install --no-cache-dir mlx-whisper 

# Copy transcription script
COPY transcribe.py .

# Define entrypoint
ENTRYPOINT ["python", "transcribe.py"]
