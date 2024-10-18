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
