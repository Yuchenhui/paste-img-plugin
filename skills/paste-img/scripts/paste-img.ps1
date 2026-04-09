# paste-img.ps1 — Capture image from Windows clipboard (native Windows)
# Usage: paste-img.ps1              → save to $env:TEMP\paste_img_<timestamp>.png
#        paste-img.ps1 output.png   → save to specified path

param(
    [string]$OutFile
)

# Ensure STA threading mode (required for clipboard access)
# pwsh 7.0-7.3 defaults to MTA and lacks -STA flag; fall back to powershell.exe (always STA)
if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    $relaunchArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $MyInvocation.MyCommand.Path)
    if ($OutFile) { $relaunchArgs += $OutFile }
    & powershell.exe @relaunchArgs
    exit $LASTEXITCODE
}

Add-Type -AssemblyName System.Windows.Forms

$img = [System.Windows.Forms.Clipboard]::GetImage()
if ($null -eq $img) {
    Write-Error "No image found in clipboard."
    exit 1
}

if (-not $OutFile) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $OutFile = Join-Path $env:TEMP "paste_img_$timestamp.png"
}

try {
    $img.Save($OutFile, [System.Drawing.Imaging.ImageFormat]::Png)
} catch {
    Write-Error "Failed to save image: $_"
    exit 1
} finally {
    $img.Dispose()
}

# Copy path to clipboard for convenience
Set-Clipboard -Value $OutFile

Write-Output $OutFile
