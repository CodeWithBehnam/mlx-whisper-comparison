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
