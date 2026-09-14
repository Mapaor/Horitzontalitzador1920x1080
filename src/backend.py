import os
import subprocess
import threading
import tempfile
import sys
from urllib.parse import unquote
# pyrefly: ignore [missing-import]
from PySide6.QtCore import QObject, Slot, Signal

from ffmpeg_runtime import get_ffmpeg_path
from settings import ALLOWED_DIMENSIONS
from utils import get_dimensions, get_duration, get_output_path, validate_animated_background
from command_builder import build_ffmpeg_command

def _clean_path(path: str) -> str:
    if not path:
        return ""
    if path.startswith("file:///"):
        path = path[8:]
    return unquote(path)

class VideoConverter(QObject):
    conversionStarted = Signal()
    conversionFinished = Signal(bool, str)
    progressUpdated = Signal(float)
    
    previewFinished = Signal(bool, str, str) # success, message, image_path
    videoInfoLoaded = Signal(str, str) # videoPath, info_string
    animatedBgCheckFinished = Signal(str) # json_string

    @Slot(str, result=str)
    def get_video_info(self, input_path: str) -> str:
        input_path = _clean_path(input_path)
        if not input_path:
            return ""
        from utils import get_video_info as _get_info
        return _get_info(input_path)

    @Slot(str, str, str, int, float, str, bool, str, int, str, bool, str, str, bool, bool, str)
    def convert(
        self,
        input_path: str,
        output_dir: str,
        output_name: str,
        blur: int,
        darkness: float,
        mode: str,
        enable_frame: bool,
        frame_color: str,
        frame_width: int,
        overlay_path: str,
        enable_overlay_recolor: bool,
        overlay_color: str,
        animated_bg_path: str,
        animated_bg_is_long: bool,
        animated_bg_is_loop: bool,
        codec_format: str
    ):
        input_path = _clean_path(input_path)
        output_dir = _clean_path(output_dir)
        overlay_path = _clean_path(overlay_path)
        animated_bg_path = _clean_path(animated_bg_path)

        self.conversionStarted.emit()
        threading.Thread(
            target=self._convert_thread,
            args=(
                input_path, output_dir, output_name, blur, darkness, mode,
                enable_frame, frame_color, frame_width,
                overlay_path, enable_overlay_recolor, overlay_color,
                animated_bg_path, animated_bg_is_long, animated_bg_is_loop, codec_format
            ),
            daemon=True
        ).start()

    def _convert_thread(
        self,
        input_path, output_dir, output_name, blur, darkness, mode,
        enable_frame, frame_color, frame_width,
        overlay_path, enable_overlay_recolor, overlay_color,
        animated_bg_path, animated_bg_is_long, animated_bg_is_loop, codec_format
    ):
        try:
            width, height = get_dimensions(input_path)
            if (width, height) not in ALLOWED_DIMENSIONS:
                raise ValueError(f"Dimensions no vàlides: {width}x{height}. Només es permet: {ALLOWED_DIMENSIONS}")

            duration = get_duration(input_path)
            output_path = get_output_path(input_path, output_dir, output_name, codec_format)

            cmd = build_ffmpeg_command(
                get_ffmpeg_path(),
                input_path,
                output_path,
                blur,
                darkness,
                mode,
                enable_frame,
                frame_color,
                frame_width,
                overlay_path,
                enable_overlay_recolor,
                overlay_color,
                animated_bg_path=animated_bg_path,
                animated_bg_is_long=animated_bg_is_long,
                animated_bg_is_loop=animated_bg_is_loop,
                codec_format=codec_format
            )

            # Inject progress flags before the output path (last element)
            output = cmd.pop()
            cmd.extend(["-progress", "pipe:1", "-nostats"])
            cmd.append(output)

            # We use creationflags=subprocess.CREATE_NO_WINDOW on windows so terminal doesn't pop up
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
            )

            error_log = []
            max_percent = 0.0
            for line in process.stdout:
                line = line.strip()
                if line.startswith("out_time_us="):
                    try:
                        val = line.split("=", 1)[1]
                        if val.lstrip('-').isdigit():
                            out_time_us = int(val)
                            if duration > 0:
                                percent = min(max(out_time_us / (duration * 1_000_000), 0.0), 1.0)
                                if percent > max_percent:
                                    max_percent = percent
                                    self.progressUpdated.emit(percent)
                    except ValueError:
                        pass
                elif line == "progress=end":
                    self.progressUpdated.emit(1.0)
                else:
                    error_log.append(line)

            process.wait()

            if process.returncode != 0:
                err_text = "\n".join(error_log[-20:]) # Keep last 20 lines of log
                print(f"FFmpeg Convert Error:\n{err_text}")
                raise RuntimeError(f"FFmpeg error:\n{err_text}")

            self.conversionFinished.emit(True, f"Vídeo desat a: {output_path}")

        except Exception as e:
            self.conversionFinished.emit(False, str(e))


    @Slot(str, int, float, str, bool, str, int, str, bool, str, str, bool, bool, str)
    def preview(
        self,
        input_path: str,
        blur: int,
        darkness: float,
        mode: str,
        enable_frame: bool,
        frame_color: str,
        frame_width: int,
        overlay_path: str,
        enable_overlay_recolor: bool,
        overlay_color: str,
        animated_bg_path: str,
        animated_bg_is_long: bool,
        animated_bg_is_loop: bool,
        codec_format: str
    ):
        input_path = _clean_path(input_path)
        overlay_path = _clean_path(overlay_path)
        animated_bg_path = _clean_path(animated_bg_path)

        threading.Thread(
            target=self._preview_thread,
            args=(
                input_path, blur, darkness, mode,
                enable_frame, frame_color, frame_width,
                overlay_path, enable_overlay_recolor, overlay_color,
                animated_bg_path, animated_bg_is_long, animated_bg_is_loop, codec_format
            ),
            daemon=True
        ).start()

    def _preview_thread(
        self,
        input_path, blur, darkness, mode,
        enable_frame, frame_color, frame_width,
        overlay_path, enable_overlay_recolor, overlay_color,
        animated_bg_path, animated_bg_is_long, animated_bg_is_loop, codec_format
    ):
        try:
            width, height = get_dimensions(input_path)
            if (width, height) not in ALLOWED_DIMENSIONS:
                raise ValueError(f"Dimensions no vàlides: {width}x{height}. Només es permet: {ALLOWED_DIMENSIONS}")

            temp_dir = tempfile.gettempdir()
            output_path = os.path.join(temp_dir, "ffmpeg_preview.jpg")

            cmd = build_ffmpeg_command(
                get_ffmpeg_path(),
                input_path,
                output_path,
                blur,
                darkness,
                mode,
                enable_frame,
                frame_color,
                frame_width,
                overlay_path,
                enable_overlay_recolor,
                overlay_color,
                is_preview=True,
                animated_bg_path=animated_bg_path,
                animated_bg_is_long=animated_bg_is_long,
                animated_bg_is_loop=animated_bg_is_loop,
                codec_format=codec_format
            )

            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
            )

            out, err = process.communicate()

            if process.returncode != 0:
                print(f"FFmpeg Preview Error:\n{err}")
                raise RuntimeError(f"FFmpeg error:\n{err}")

            self.previewFinished.emit(True, "Previsualització generada.", f"file:///{output_path.replace(os.sep, '/')}")

        except Exception as e:
            self.previewFinished.emit(False, str(e), "")

    @Slot(str)
    def open_and_select_file(self, file_path: str):
        file_path = _clean_path(file_path)
        if not os.path.exists(file_path):
            return
            
        try:
            if sys.platform == 'win32':
                subprocess.Popen(['explorer', '/select,', os.path.normpath(file_path)])
            elif sys.platform == 'darwin':
                subprocess.Popen(['open', '-R', file_path])
            else:
                subprocess.Popen(['xdg-open', os.path.dirname(file_path)])
        except Exception as e:
            print(f"Error opening file: {e}")

    @Slot(str, str)
    def check_animated_bg_async(self, bg_path: str, input_path: str):
        bg_path = _clean_path(bg_path)
        input_path = _clean_path(input_path)
        
        if not bg_path:
            self.animatedBgCheckFinished.emit("{}")
            return
            
        threading.Thread(
            target=self._check_animated_bg_thread,
            args=(bg_path, input_path),
            daemon=True
        ).start()

    def _check_animated_bg_thread(self, bg_path, input_path):
        import json
        try:
            input_duration = 0.0
            if input_path and os.path.exists(input_path):
                from utils import get_duration
                input_duration = get_duration(input_path)
                
            res = validate_animated_background(bg_path, input_duration)
            self.animatedBgCheckFinished.emit(json.dumps(res))
        except Exception as e:
            self.animatedBgCheckFinished.emit(json.dumps({"error": str(e)}))
