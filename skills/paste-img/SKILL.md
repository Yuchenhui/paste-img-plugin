---
name: paste-img
description: "Capture image from Windows clipboard in WSL and display it in conversation. Use when the user wants to paste, share, or show a screenshot or clipboard image."
argument-hint: "[description of what to do with the image]"
allowed-tools: [Bash, Read]
---

Capture an image from the Windows clipboard and display it in the conversation.

## Steps

1. Run the capture script:
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/skills/paste-img/scripts/paste-img.sh"
   ```
2. If the script succeeds, read the image file at the returned path using the Read tool.
3. If `$ARGUMENTS` is provided, follow the user's instructions regarding the image (e.g., analyze, describe, compare).
   Otherwise, describe what you see in the image and ask the user what they'd like to do with it.

## Error handling

- If the script outputs "剪贴板中没有图片", tell the user to first take a screenshot (e.g., Win+Shift+S) and then retry.
- If the script outputs "无法访问 PowerShell", tell the user this plugin requires WSL with Windows interop enabled.

$ARGUMENTS
