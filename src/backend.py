import os
import subprocess
import threading
import tempfile
from urllib.parse import unquote
# pyrefly: ignore [missing-import]
from PySide6.QtCore import QObject, Slot, Signal

from ffmpeg_runtime import get_ffmpeg_path
from settings import ALLOWED_DIMENSIONS
from utils import get_dimensions, get_duration, get_output_path
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

    @Slot(str, str, str, int, float, str, bool, str, int, str, bool, str)
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
        overlay_color: str
    ):
        input_path = _clean_path(input_path)
        output_dir = _clean_path(output_dir)
        overlay_path = _clean_path(overlay_path)

        self.conversionStarted.emit()
        threading.Thread(
            target=self._convert_thread,
            args=(
                input_path, output_dir, output_name, blur, darkness, mode,
                enable_frame, frame_color, frame_width,
                overlay_path, enable_overlay_recolor, overlay_color
            ),
            daemon=True
        ).start()

    def _convert_thread(
        self,
        input_path, output_dir, output_name, blur, darkness, mode,
        enable_frame, frame_color, frame_width,
        overlay_path, enable_overlay_recolor, overlay_color
    ):
        try:
            width, height = get_dimensions(input_path)
            if (width, height) not in ALLOWED_DIMENSIONS:
                raise ValueError(f"Dimensions no vàlides: {width}x{height}. Només es permet: {ALLOWED_DIMENSIONS}")

            duration = get_duration(input_path)
            output_path = get_output_path(input_path, output_dir, output_name)

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
            )

            # Inject progress flags before the output path (last element)
            output = cmd.pop()
            cmd.extend(["-progress", "pipe:1", "-nostats"])
            cmd.append(output)

            # We use creationflags=subprocess.CREATE_NO_WINDOW on windows so terminal doesn't pop up
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
            )

            for line in process.stdout:
                line = line.strip()
                if line.startswith("out_time_us="):
                    try:
                        out_time_us = int(line.split("=", 1)[1])
                        if duration > 0:
                            percent = min(out_time_us / (duration * 1_000_000), 1.0)
                            self.progressUpdated.emit(percent)
                    except ValueError:
                        pass
                elif line == "progress=end":
                    self.progressUpdated.emit(1.0)

            process.wait()

            if process.returncode != 0:
                raise RuntimeError("FFmpeg ha retornat un error.")

            self.conversionFinished.emit(True, f"Vídeo desat a:\n\n{output_path}")

        except Exception as e:
            self.conversionFinished.emit(False, str(e))


    @Slot(str, int, float, str, bool, str, int, str, bool, str)
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
        overlay_color: str
    ):
        input_path = _clean_path(input_path)
        overlay_path = _clean_path(overlay_path)

        threading.Thread(
            target=self._preview_thread,
            args=(
                input_path, blur, darkness, mode,
                enable_frame, frame_color, frame_width,
                overlay_path, enable_overlay_recolor, overlay_color
            ),
            daemon=True
        ).start()

    def _preview_thread(
        self,
        input_path, blur, darkness, mode,
        enable_frame, frame_color, frame_width,
        overlay_path, enable_overlay_recolor, overlay_color
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
            )

            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
            )

            process.communicate()

            if process.returncode != 0:
                raise RuntimeError("FFmpeg ha retornat un error en previsualitzar.")

            self.previewFinished.emit(True, "Previsualització generada.", f"file:///{output_path.replace(os.sep, '/')}")

        except Exception as e:
            self.previewFinished.emit(False, str(e), "")
