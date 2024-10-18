# services/whisper_turbo/Dockerfile
FROM python:3.12-slim

# Install system dependencies including ffmpeg
RUN apt-get update && apt-get install -y git ffmpeg && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Clone the whisper-turbo-mlx repository
RUN git clone https://github.com/JosefAlbers/whisper-turbo-mlx.git

# Navigate to the repository directory
WORKDIR /app/whisper-turbo-mlx

RUN pip install -U --no-cache-dir pip

RUN pip install --no-cache-dir mlx
# Install the whisper-turbo-mlx package in editable mode
RUN pip install --no-cache-dir -e .

# Copy transcription script
COPY transcribe.py .

# Define entrypoint
ENTRYPOINT ["python", "transcribe.py"]