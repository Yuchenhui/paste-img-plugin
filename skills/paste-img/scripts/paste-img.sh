#!/bin/bash
# paste-img.sh — 从 Windows 剪贴板保存图片到 WSL，输出文件路径并复制到 Windows 剪贴板
# 用法: paste-img.sh          → 保存到 /tmp/paste_img_<timestamp>.png
#       paste-img.sh foo.png  → 保存到指定路径

PS="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
CLIP="/mnt/c/Windows/System32/clip.exe"

# 检查 PowerShell 是否可用（WSL interop）
if [ ! -x "$PS" ]; then
    echo "错误: 无法访问 PowerShell，请确认在 WSL 环境中运行且 interop 已启用" >&2
    exit 1
fi

if [ -n "$1" ]; then
    outfile="$(realpath "$1" 2>/dev/null || echo "$1")"
else
    outfile="/tmp/paste_img_$(date +%Y%m%d_%H%M%S).png"
fi

# 获取 Windows 临时文件路径
win_path=$($PS -STA -NoProfile -Command "[System.IO.Path]::GetTempFileName()" 2>/dev/null | tr -d '\r')
if [ -z "$win_path" ]; then
    echo "错误: 无法调用 PowerShell" >&2
    exit 1
fi
win_png="${win_path%.tmp}.png"

# 用 PowerShell 从剪贴板保存图片（需要 -STA 模式访问剪贴板）
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
    echo "错误: 剪贴板中没有图片" >&2
    $PS -STA -NoProfile -Command "Remove-Item '$win_path','$win_png' -ErrorAction SilentlyContinue" &>/dev/null
    exit 1
fi

# 将 Windows 临时文件复制到 WSL 目标路径
wsl_tmp=$(wslpath "$win_png" 2>/dev/null)
if [ -n "$wsl_tmp" ] && [ -f "$wsl_tmp" ]; then
    mv "$wsl_tmp" "$outfile"
else
    # fallback: 通过 PowerShell 读取字节
    $PS -STA -NoProfile -Command "[Convert]::ToBase64String([IO.File]::ReadAllBytes('$win_png'))" | tr -d '\r' | base64 -d > "$outfile"
fi

# 清理 Windows 临时文件
$PS -STA -NoProfile -Command "Remove-Item '$win_path','$win_png' -ErrorAction SilentlyContinue" &>/dev/null &

# 将路径复制到 Windows 剪贴板
if [ -x "$CLIP" ]; then
    printf '%s' "$outfile" | "$CLIP" 2>/dev/null
fi

echo "$outfile"
