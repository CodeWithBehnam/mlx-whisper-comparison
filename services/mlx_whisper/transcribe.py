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
