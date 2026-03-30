#!/bin/bash
# paste-img.sh — Capture image from Windows clipboard and save to WSL
# Usage: paste-img.sh          → save to /tmp/paste_img_<timestamp>.png
#        paste-img.sh foo.png  → save to specified path

PS="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
CLIP="/mnt/c/Windows/System32/clip.exe"

# Check PowerShell availability (WSL interop)
if [ ! -x "$PS" ]; then
    echo "Error: Cannot access PowerShell. Make sure you are running in WSL with interop enabled." >&2
    exit 1
fi

if [ -n "$1" ]; then
    outfile="$(realpath "$1" 2>/dev/null || echo "$1")"
else
    outfile="/tmp/paste_img_$(date +%Y%m%d_%H%M%S).png"
fi

# Get Windows temp file path
win_path=$($PS -STA -NoProfile -Command "[System.IO.Path]::GetTempFileName()" 2>/dev/null | tr -d '\r')
if [ -z "$win_path" ]; then
    echo "Error: Failed to invoke PowerShell." >&2
    exit 1
fi
win_png="${win_path%.tmp}.png"

# Save clipboard image via PowerShell (-STA mode required for clipboard access)
result=$($PS -STA -NoProfile -Command "
Add-Type -AssemblyName System.Windows.Forms
\$img = [System.Windows.Forms.Clipboard]::GetImage()
if (\$img -eq \$null) {
    Write-Error 'EMPTY'
    exit 1
}
\$img.Save('$win_png', [System.Drawing.Imaging.ImageFormat]::Png)
\$img.Dispose()
Write-Output 'OK'
" 2>&1 | tr -d '\r')

if [ "$result" != "OK" ]; then
    echo "Error: No image found in clipboard." >&2
    $PS -STA -NoProfile -Command "Remove-Item '$win_path','$win_png' -ErrorAction SilentlyContinue" &>/dev/null
    exit 1
fi

# Copy Windows temp file to WSL target path
wsl_tmp=$(wslpath "$win_png" 2>/dev/null)
if [ -n "$wsl_tmp" ] && [ -f "$wsl_tmp" ]; then
    mv "$wsl_tmp" "$outfile"
else
    # fallback: read bytes via PowerShell
    $PS -STA -NoProfile -Command "[Convert]::ToBase64String([IO.File]::ReadAllBytes('$win_png'))" | tr -d '\r' | base64 -d > "$outfile"
fi

# Clean up Windows temp files
$PS -STA -NoProfile -Command "Remove-Item '$win_path','$win_png' -ErrorAction SilentlyContinue" &>/dev/null &

# Copy file path to Windows clipboard
if [ -x "$CLIP" ]; then
    printf '%s' "$outfile" | "$CLIP" 2>/dev/null
fi

echo "$outfile"
