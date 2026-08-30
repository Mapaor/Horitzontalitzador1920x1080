# PySide6 + QML App Template

Minimal starter template for building a PySide6 QML desktop app and packaging it into a Windows executable with PyInstaller.

## Structure

- `src/main.py` — application entry point
- `src/qml/` — QML modules and files
- `pyinstaller/` — PyInstaller spec and runtime helpers
- `requirements.txt` — Python dependencies for this project
- `README.md` — project notes
- `.gitignore` — excludes local environment and generated build output

Do not commit generated folders such as `build/` or `dist/`.

## Setup

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```

Also select the corresponding python interpreter in your IDE. On VSCode: Ctrl+Shift+P > Python: Select Interpreter: venv.

For the default Run code button in VS Code to use the project virtual environment, keep the workspace interpreter selected and use the repo's `.vscode/settings.json` configuration so Code Runner executes `$pythonPath -u $fullFileName` instead of the system Python.

Recommended VSCode Extensions: QT Core, QT Python and QT QML.

## Develop
Develop as you wish, run `main.py` to see the application running.

## Build the executable

First add pyinstaller to the path of MyApp.spec.
```powershell
python -m PyInstaller .\pyinstaller\MyApp.spec --noconfirm
```

Then build the executable.
```powershell
pyinstaller .\pyinstaller\MyApp.spec --noconfirm
```

The built app will be created under `dist/`.

## External assets

The repository-level `ffmpeg/` directory must contain `ffmpeg.exe` and `ffprobe.exe`.
The app resolves these files from the repository root in development and from
PyInstaller's temporary extraction directory in a bundled build. The PyInstaller
spec includes the directory in `dist/` and the app checks that FFmpeg can start
before opening the UI.
