from pathlib import Path

# =====================================
# Projecte
# =====================================

APP_NAME = "Horitzontalitzador3Cat"
APP_VERSION = "1.0.0"

# =====================================
# Directoris
# =====================================

ROOT_DIR = Path(__file__).resolve().parent.parent

SRC_DIR = ROOT_DIR / "src"

ASSETS_DIR = ROOT_DIR / "assets"

ICON_PATH = ASSETS_DIR / "icon.ico"

FFMPEG_DIR = ROOT_DIR / "ffmpeg"

# =====================================
# FFmpeg
# =====================================

OUTPUT_WIDTH = 1920
OUTPUT_HEIGHT = 1080

DEFAULT_CRF = 23

DEFAULT_BLUR = 30

DEFAULT_DARKNESS = -0.10

DEFAULT_MODE = "Zoom"

VIDEO_EXTENSIONS = (
    "*.mp4",
    "*.mov",
    "*.mkv",
    "*.avi",
    "*.webm",
)

ALLOWED_DIMENSIONS = [
    (1080, 1920),
    (720, 1280),
]

# =====================================
# GUI
# =====================================

WINDOW_WIDTH = 520
WINDOW_HEIGHT = 500

THEME = str(ASSETS_DIR / "themes" / "magenta.json")

APPEARANCE = "System"

FONT_FAMILY = "Bw3Cat"

# =====================================
# Preview
# =====================================

PREVIEW_WIDTH = 480
PREVIEW_HEIGHT = 270

PREVIEW_TEMP_FILE = ROOT_DIR / "preview.jpg"

# =====================================
# Slider Blur
# =====================================

BLUR_MIN = 5
BLUR_MAX = 60
BLUR_STEPS = 55

# =====================================
# Slider Darkness
# =====================================

DARKNESS_MIN = -0.60
DARKNESS_MAX = 0.00
DARKNESS_STEPS = 60

# =====================================
# Slider Frame Width
# =====================================

FRAME_WIDTH_MIN = 2
FRAME_WIDTH_MAX = 50
FRAME_WIDTH_STEPS = 48
DEFAULT_FRAME_WIDTH = 10

# =====================================
# Frame
# =====================================

DEFAULT_ENABLE_FRAME = False
DEFAULT_FRAME_COLOR = "#000000"

# =====================================
# Overlay Image
# =====================================

DEFAULT_OVERLAY_IMAGE = ""
DEFAULT_ENABLE_RECOLOR_OVERLAY = False
DEFAULT_RECOLOR_OVERLAY_COLOR = "#000000"
