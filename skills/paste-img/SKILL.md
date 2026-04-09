---
name: paste-img
description: "Capture image from Windows clipboard and display it in conversation. Works in both WSL and native Windows (PowerShell/pwsh) environments."
argument-hint: "[description of what to do with the image]"
allowed-tools: [Bash, Read]
---

Capture an image from the Windows clipboard and display it in the conversation.

## Steps

1. Detect the runtime environment:
   ```bash
   uname -s 2>/dev/null || echo "WINDOWS"
   ```
   - If output contains **"Linux"**: this is a **WSL** environment.
   - Otherwise (output is "WINDOWS", "MINGW", etc.): this is a **native Windows** environment.

2. Run the capture script for the detected environment:
   - **WSL**:
     ```bash
     bash "${CLAUDE_PLUGIN_ROOT}/skills/paste-img/scripts/paste-img.sh"
     ```
   - **Native Windows**:
     ```powershell
     powershell.exe -STA -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/paste-img/scripts/paste-img.ps1"
     ```

3. If the script succeeds, read the image file at the returned path using the Read tool.
4. If `$ARGUMENTS` is provided, follow the user's instructions regarding the image (e.g., analyze, describe, compare).
   Otherwise, describe what you see in the image and ask the user what they'd like to do with it.

## Error handling

- If the script outputs "No image found in clipboard", tell the user to first take a screenshot (e.g., Win+Shift+S) and then retry.
- If the script outputs "Cannot access PowerShell" (WSL), tell the user this plugin requires WSL with Windows interop enabled.
- If PowerShell reports STA threading errors, suggest running Claude Code from `powershell.exe` instead of `pwsh`, or upgrading pwsh to 7.4+.

$ARGUMENTS
