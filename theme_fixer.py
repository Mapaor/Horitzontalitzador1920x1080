import os
from pathlib import Path

qml_dir = Path(r"c:\Users\PC\Documents\GitHub\PythonApps\Horitzontalitzador3Cat\src\qml\MyApp")

def replace_in_file(filename, old, new):
    path = qml_dir / filename
    if not path.exists():
        path = qml_dir / "components" / filename
    if not path.exists():
        return
        
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    content = content.replace(old, new)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

# Fix backgrounds that became black
replace_in_file("ConfigPanel.qml", 'color: "#000000"\n    radius: 12', 'color: "#ffffff"\n    radius: 12')
replace_in_file("ConfigPanel.qml", ' : "#000000"\n                            radius: 8', ' : "#ffffff"\n                            radius: 8')

replace_in_file("FooterPanel.qml", 'color: "#000000"\n    radius: 12', 'color: "#ffffff"\n    radius: 12')

replace_in_file("IoPanel.qml", 'color: "#000000"\n    radius: 12', 'color: "#ffffff"\n    radius: 12')

replace_in_file("StatusPanel.qml", 'color: "#000000"\n    radius: 12', 'color: "#ffffff"\n    radius: 12')

replace_in_file("AppPopups.qml", 'background: Rectangle { color: "#000000"; radius: 12;', 'background: Rectangle { color: "#ffffff"; radius: 12;')

# Check if text colors in primary buttons got messed up.
# Wait, `#ffffff` -> `#000000` means all white texts became black. 
# Some white text on pink buttons might look better as white.
# Let's see if we want to change some button texts back to white.
# FooterPanel.qml line 144: text for Convertir button.
# `color: parent.enabled ? "#000000" : "#b9b9b9"` -> should be `#ffffff` when enabled.
replace_in_file("FooterPanel.qml", 'color: parent.enabled ? "#000000" : "#b9b9b9"; font.bold: true; font.pixelSize: 16', 'color: parent.enabled ? "#ffffff" : "#b9b9b9"; font.bold: true; font.pixelSize: 16')
# ActionPanel.qml
replace_in_file("ActionPanel.qml", 'color: parent.enabled ? "#000000" : "#b9b9b9"; font.bold: true; font.pixelSize: 16', 'color: parent.enabled ? "#ffffff" : "#b9b9b9"; font.bold: true; font.pixelSize: 16')

# Check text fields in FooterPanel and IoPanel
# In FooterPanel, `id: nameEntry`, text is `color: "#000000"`, background is `Rectangle { color: "#d7d7d5";`
# That is fine for light theme!

print("Fix applied.")
