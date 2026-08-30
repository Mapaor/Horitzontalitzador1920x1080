import os
import subprocess

from ffmpeg_runtime import get_ffprobe_path

def get_output_path(input_path, output_dir=None, output_name=None):
    if output_dir:
        directory = output_dir
    else:
        directory = os.path.dirname(input_path)
        
    filename = os.path.basename(input_path)
    original_name, extension = os.path.splitext(filename)
    
    if output_name:
        name = output_name
    else:
        name = f"{original_name}_16x9"
        
    return os.path.join(
        directory,
        f"{name}{extension}",
    )

def get_duration(input_path) -> float:
    """Return the total duration of the video in seconds."""
    cmd = [
        str(get_ffprobe_path()),
        "-v", "error",
        "-show_entries", "format=duration",
        "-of", "default=noprint_wrappers=1:nokey=1",
        input_path
    ]

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    if result.returncode != 0:
        raise RuntimeError("No s'ha pogut obtenir la durada del vídeo.")

    try:
        return float(result.stdout.strip())
    except Exception:
        raise RuntimeError("Error a l'obtenir la durada del vídeo.")

def get_dimensions(input_path):
    cmd = [
        str(get_ffprobe_path()),
        "-v", "error",
        "-select_streams", "v:0",
        "-show_entries", "stream=width,height",
        "-of", "csv=s=x:p=0",
        input_path
    ]

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    if result.returncode != 0:
        raise RuntimeError("No s'ha pogut analitzar el vídeo amb ffprobe.")

    try:
        width_str, height_str = result.stdout.strip().split("x")
        return int(width_str), int(height_str)
    except Exception:
        raise RuntimeError("Error a l'obtenir les dimensions del vídeo.")
