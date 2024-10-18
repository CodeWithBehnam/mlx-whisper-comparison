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
