# Horitzontalitzador 1920x1080

Una app feta amb PySide6 (Python i Qt6) que desplega una UI moderna per utilitzar ffmpeg internament amb l'objectiu de manipular vídeos (per exemple verticals gravats amb un mòbil) per horitzontalitzar-los en FullHD 16:9 amb el fons desenfocat.
<img width="959" height="505" alt="horitzontalitzador-captura-1" src="https://github.com/user-attachments/assets/4dc24452-156e-43d4-82e8-118d0102b85a" />

<details><summary>Més captures</summary>



<img width="529" height="451" alt="h-captura-2" src="https://github.com/user-attachments/assets/f08241bd-827b-42fb-9858-17e087388431" />
<img width="945" height="481" alt="h-captura-3" src="https://github.com/user-attachments/assets/f5694712-ff92-49f3-887e-fce1dffa19f9" />
<img width="959" height="505" alt="h-captura-5" src="https://github.com/user-attachments/assets/0f0d7619-a56d-46a0-8e06-e802cb880232" />
</details>
## Estructura

- `src/main.py` — Des d'on s'executa la app
- `src/qml/` — Mòduls i components QML
- `pyinstaller/` — Fitxers de configuració relacionats amb PyInstaller i runtime helpers per aconseguir generar l'executable
- `requirements.txt` — Dependències Python que cal instal·lar
- `fonts/` hi ha la tipografia utilitzada (en aquest cas la de 3Cat)
- `ffmpeg/` hi ha els binaris ffmpeg.exe i ffprobe.exe

Important mantenir en el gitignore les carpetes `build/` i `dist/` i l'entorn virtual de python `.venv/`.

## Requisits
Un IDE (per exemple VSCode), python 3.10 o superior i pip. 

Tenir PowerShell a la terminal serà útil per assegurar que funcionen els següents comandaments.

També recomanaria les extensions del VsCode "QT Core", "QT QML" i "QT Python".

## Preparació

A una terminal fer:
```powershell
python -m venv .venv
```
```powershell
.\.venv\Scripts\Activate.ps1
```
```powershell
python -m pip install --upgrade pip
```
```powershell
pip install -r requirements.txt
```

I també seleccionar l'entorn virtual com a Python Interpeter en el IDE que sigui que utilitzes. En el VSCode: Ctrl+Shift+P > Python: Select Interpreter: venv.

A dins de `.vscode/settings.json` i `.vscode/launch.json` hi ha una configuració per permetre executar la app clicant el botó "Run" que apareix a dalt a la dreta d'el fitxer python `main.py`.

## Desenvolupament
Desenvolupa l'aplicació al teu gust, simplement anar fent  canvis i executant `main.py` per veure'ls.

Nota: L'activació de l'entorn virtual l'hauràs de fer cada vegada que obris l'IDE (`.\.venv\Scripts\Activate.ps1`).

## Generar l'executable

Primer cal afegir pyinstaller al path de MyApp.spec.
```powershell
python -m PyInstaller .\pyinstaller\MyApp.spec --noconfirm
```

I ara generem l'executable fent...
```powershell
pyinstaller .\pyinstaller\MyApp.spec --noconfirm
```

El `.exe` es generarà dins de la carpeta `dist/`, es dirà `MyApp.exe` però li pots canviar el nom sense problemes.

## Llicència

[MIT](/LICENSE)

El codi de la aplicació PySide6 té llicència MIT (permissiva), els binaris de ffmpeg tenen una llicència també permisiva (LGPL 2.1), la font BW3Cat té la seva respectiva llicència propietària.
