# services/plotter/Dockerfile
FROM python:3.12

# Install system dependencies including ffmpeg (if necessary)
RUN apt-get update && apt-get install -y git ffmpeg && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

RUN pip install -U --no-cache-dir pip 

# Install required Python packages
RUN pip install --no-cache-dir matplotlib pandas mlx 


# Copy plotting script
COPY plot.py .

# Define entrypoint
ENTRYPOINT ["python", "plot.py"]
