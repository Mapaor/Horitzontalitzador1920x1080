import os
import subprocess
import json
import tempfile

from ffmpeg_runtime import get_ffprobe_path, get_ffmpeg_path

def get_video_info(input_path: str) -> str:
    cmd = [
        str(get_ffprobe_path()),
        "-v", "error",
        "-select_streams", "v:0",
        "-show_entries", "format=format_name:stream=width,height,r_frame_rate,codec_name",
        "-of", "json",
        input_path
    ]
    try:
        flags = subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, creationflags=flags)
        if result.returncode != 0:
            return "Error a l'obtenir les propietats."
        data = json.loads(result.stdout)
        
        format_name = data.get("format", {}).get("format_name", "Desconegut").split(',')[0].upper()
        stream = data.get("streams", [{}])[0]
        width = stream.get("width", "?")
        height = stream.get("height", "?")
        fps_str = stream.get("r_frame_rate", "0/1")
        codec = stream.get("codec_name", "Desconegut").upper()
        
        # Calculate fps
        try:
            num, den = fps_str.split('/')
            if den != '0':
                fps = round(int(num) / int(den), 2)
                if fps.is_integer():
                    fps = int(fps)
            else:
                fps = "?"
        except ValueError:
            fps = fps_str
            
        return f"{width}x{height} • {fps} FPS • {format_name} • {codec}"
    except Exception:
        return "Propietats no disponibles"

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
        
    return os.path.normpath(os.path.join(
        directory,
        f"{name}{extension}",
    ))

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

def validate_animated_background(bg_path: str, input_duration: float) -> dict:
    result = {
        "format_ok": False,
        "format_msg": "",
        "loop_ok": False,
        "loop_msg": "",
        "duration_msg": "",
        "can_proceed": False
    }

    # 1. Check format (MOV, 1920x1080, Alpha)
    cmd = [
        str(get_ffprobe_path()),
        "-v", "error",
        "-select_streams", "v:0",
        "-show_entries", "format=format_name:stream=width,height,pix_fmt",
        "-of", "json",
        bg_path
    ]
    flags = subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
    try:
        proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, creationflags=flags)
        if proc.returncode != 0:
            result["format_msg"] = "Error llegint format"
            return result
        
        data = json.loads(proc.stdout)
        fmt_name = data.get("format", {}).get("format_name", "").lower()
        stream = data.get("streams", [{}])[0]
        width = stream.get("width", 0)
        height = stream.get("height", 0)
        pix_fmt = stream.get("pix_fmt", "").lower()

        is_mov = "mov" in fmt_name or "quicktime" in fmt_name or "mp4" in fmt_name
        is_1080p = (width == 1920 and height == 1080)
        has_alpha = "a" in pix_fmt or "yuva" in pix_fmt or "rgba" in pix_fmt or "argb" in pix_fmt or "bgra" in pix_fmt

        fmt_ext = ".MOV" if is_mov else ".MP4/MOV"
        res_str = f"{width}x{height}" if (width and height) else "?x?"
        alpha_str = "RGBA" if has_alpha else "RGB"

        color_green = "#10b981"
        color_red = "#ef4444"

        fmt_color = color_green if is_mov else color_red
        res_color = color_green if is_1080p else color_red
        alpha_color = color_green if has_alpha else color_red

        result["format_msg"] = f"<font color='{fmt_color}'>{fmt_ext}</font> <font color='#969798'>·</font> <font color='{res_color}'>{res_str}</font> <font color='#969798'>·</font> <font color='{alpha_color}'>{alpha_str}</font>"
        result["format_ok"] = is_mov and is_1080p and has_alpha
    except Exception as e:
        result["format_msg"] = f"<font color='#ef4444'>Error: {e}</font>"
        return result

    # 2. Check duration
    try:
        bg_duration = get_duration(bg_path)
    except Exception:
        result["duration_msg"] = "DURACIÓ DESCONEGUDA"
        return result

    def fmt_time(seconds):
        m, s = divmod(int(seconds), 60)
        return f"{m}:{s:02d}"

    result["duration_msg"] = f"DURACIÓ {fmt_time(bg_duration)} (Duració input {fmt_time(input_duration)})"
    
    # 3. Check loop always
    is_long = bg_duration >= input_duration
    result["is_long"] = is_long

    with tempfile.TemporaryDirectory() as tmpdir:
        first_frame_path = os.path.join(tmpdir, "first.png")
        last_frame_path = os.path.join(tmpdir, "last.png")

        # Extract first frame
        subprocess.run([
            str(get_ffmpeg_path()), "-v", "error", "-i", bg_path,
            "-vframes", "1", first_frame_path
        ], creationflags=flags)

        # Extract last frame (seek 1 second from end to be safe, override updates until EOF)
        subprocess.run([
            str(get_ffmpeg_path()), "-v", "error", "-sseof", "-1", "-i", bg_path,
            "-update", "1", "-q:v", "1", last_frame_path
        ], creationflags=flags)

        if os.path.exists(first_frame_path) and os.path.exists(last_frame_path):
            ssim_cmd = [
                str(get_ffmpeg_path()),
                "-i", first_frame_path, "-i", last_frame_path,
                "-lavfi", "ssim", "-f", "null", "-"
            ]
            ssim_proc = subprocess.run(ssim_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, creationflags=flags)
            
            output = ssim_proc.stderr
            all_ssim = 0.0
            for line in output.split('\n'):
                if "All:" in line:
                    try:
                        part = line.split("All:")[1].split()[0]
                        all_ssim = float(part)
                    except Exception:
                        pass
                    break
            
            if all_ssim >= 0.95:
                result["loop_ok"] = True
                result["loop_msg"] = f"LOOP OK ({all_ssim:.3f})"
            else:
                result["loop_ok"] = False
                result["loop_msg"] = f"NO LOOP ({all_ssim:.3f})"
        else:
            result["loop_ok"] = False
            result["loop_msg"] = "ERROR LOOP"

    result["can_proceed"] = result["format_ok"] and (result["loop_ok"] or result["is_long"])
    return result
