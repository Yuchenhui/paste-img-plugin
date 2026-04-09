# paste-img

A Claude Code plugin that lets you paste Windows clipboard images directly into your conversation. Works in both **WSL** and **native Windows** (PowerShell/pwsh) environments.

## The Problem

When using Claude Code on Windows, sharing screenshots requires a tedious workflow:

1. Take a screenshot on Windows
2. Save it to disk manually
3. Find the file path
4. Pass the path to Claude

This breaks the flow of conversation, especially when you need to share screenshots frequently for UI reviews, debugging, or visual discussions.

## The Solution

This plugin adds a `/paste-img` slash command that captures the image from your Windows clipboard and displays it in the conversation — all in one step.

## How It Works

1. Take a screenshot on Windows (e.g., `Win+Shift+S`)
2. Type `/paste-img` in Claude Code
3. The image appears in your conversation instantly

You can also add instructions along with the image:

```
/paste-img analyze the layout of this page
```

The plugin auto-detects your environment and uses the appropriate method:

| Environment | Method |
|---|---|
| **WSL** | Calls PowerShell from WSL with `-STA` mode, saves to `/tmp/` |
| **Native Windows** (PowerShell/pwsh) | Runs PowerShell script directly, saves to `$env:TEMP` |

## Requirements

**WSL:**
- WSL with Windows interop enabled (`/mnt/c/` accessible)
- PowerShell available at `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`

**Native Windows:**
- PowerShell 5.1 (`powershell.exe`) or PowerShell 7.4+ (`pwsh`)
- For pwsh 7.0-7.3, the script auto-falls back to `powershell.exe`

**Both:**
- Claude Code CLI

## Installation

```bash
claude plugins marketplace add Yuchenhui/paste-img-plugin
claude plugins install paste-img@paste-img-plugin
```


Restart your Claude Code session after installation.

## License

MIT
