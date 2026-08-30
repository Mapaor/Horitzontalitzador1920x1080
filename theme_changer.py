import os
from pathlib import Path
import re

qml_dir = Path(r"c:\Users\PC\Documents\GitHub\PythonApps\Horitzontalitzador3Cat\src\qml\MyApp")

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Colors mapping
    # Let's map step by step
    
    # 1. Main background
    content = content.replace('"#0f141e"', '"#d7d7d5"')
    # 2. Panel backgrounds
    content = content.replace('"#1c2436"', '"#ffffff"')
    # 3. Borders
    content = content.replace('"#35415a"', '"#b9b9b9"')
    
    # 4. Button states (Secondary)
    content = content.replace('"#28334a"', '"#d7d7d5"') # normal button bg
    content = content.replace('"#2d3a54"', '"#b9b9b9"') # hover button bg
    content = content.replace('"#232d44"', '"#969798"') # pressed button bg
    
    # 5. Primary button / Accents (The pinks)
    content = content.replace('"#3a76ff"', '"#e9456c"')
    content = content.replace('"#4f8aff"', '"#d4365b"')
    content = content.replace('"#6597ff"', '"#be2649"')
    content = content.replace('"#4ade80"', '"#e9456c"') # progress bar fill
    
    # 6. Secondary Texts
    content = content.replace('"#a9b8cc"', '"#969798"')
    content = content.replace('"#5a6a84"', '"#b9b9b9"') # disabled text
    
    # 7. Error/Success
    content = content.replace('"#ff5555"', '"#be2649"')
    
    # 8. White -> Black for texts. BUT be careful about button texts.
    # We can replace `#ffffff` with `#000000` EXCEPT when it's on a button.
    # Actually, if we just use black text everywhere, it might be fine, but white on pink is better.
    # Let's manually replace white with black, but change it back to white for specific things if needed.
    # Alternatively, any color: "#ffffff" becomes color: "#000000"
    content = content.replace('"#ffffff"', '"#000000"')
    
    # Let's fix primary button text to be white!
    # In FooterPanel: contentItem: Text { text: parent.text; color: parent.enabled ? "#ffffff" : ...
    # Now it would be "#000000", let's leave it as black, it might look okay on pink. Or change it back:
    content = content.replace('color: parent.enabled ? "#000000" : "#b9b9b9"', 'color: parent.enabled ? "#ffffff" : "#b9b9b9"')
    
    # In ActionPanel (add to queue):
    # contentItem: Text { text: parent.text; color: parent.enabled ? "#ffffff" : ...
    # Also in ConfigPanel, secondary buttons text color:
    # contentItem: Text { text: parent.text; color: parent.enabled ? "#000000" : "#b9b9b9"
    # Actually let's make the text of primary buttons "#ffffff".
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

for root, dirs, files in os.walk(qml_dir):
    for file in files:
        if file.endswith('.qml'):
            process_file(os.path.join(root, file))

print("Theme updated successfully.")
