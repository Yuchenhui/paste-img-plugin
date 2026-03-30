# paste-img

A Claude Code plugin that lets you paste Windows clipboard images directly into your conversation when running on WSL.

## The Problem

When using Claude Code in WSL, sharing screenshots requires a tedious workflow:

1. Take a screenshot on Windows
2. Save it to disk manually
3. Find the file path
4. Convert the Windows path to a WSL path
5. Pass the path to Claude

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

Under the hood, the plugin calls PowerShell from WSL (with `-STA` mode for clipboard access) to capture the image, saves it to `/tmp/`, and copies the file path to your Windows clipboard for easy reference.

## Requirements

- **WSL** with Windows interop enabled (`/mnt/c/` accessible)
- **PowerShell** available at `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`
- **Claude Code** CLI

## Installation

```bash
claude plugins marketplace add Yuchenhui/paste-img-plugin
claude plugins install paste-img@paste-img-plugin
```

Restart your Claude Code session after installation.

## License

MIT
