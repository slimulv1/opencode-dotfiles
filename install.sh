#!/usr/bin/env bash
# Cài đặt opencode-dotfiles: config + skills + plugins + memory
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
SKILLS_DIR="$HOME/.agents/skills"
WORKTREE_DIR="$HOME/.opencode/plugins/worktree"
MEM_DIR="$HOME/.opencode-mem/data"

echo "==> [1/4] Copy config -> $CONFIG_DIR"
mkdir -p "$CONFIG_DIR"
cp -r "$REPO_DIR/config/." "$CONFIG_DIR/"
# Sửa đường dẫn tuyệt đối /home/magnus -> $HOME của máy hiện tại
grep -rl '/home/magnus' "$CONFIG_DIR" 2>/dev/null | while read -r f; do
  sed -i "s|/home/magnus|$HOME|g" "$f"
  echo "    đã sửa đường dẫn: ${f#$CONFIG_DIR/}"
done

echo "==> [2/4] Copy skills -> $SKILLS_DIR"
mkdir -p "$SKILLS_DIR"
cp -r "$REPO_DIR/skills/." "$SKILLS_DIR/"

echo "==> [3/4] Copy plugin worktree -> $WORKTREE_DIR"
mkdir -p "$WORKTREE_DIR"
cp -r "$REPO_DIR/plugins/worktree/." "$WORKTREE_DIR/"
if grep -rl '/home/magnus' "$WORKTREE_DIR" 2>/dev/null; then
  sed -i "s|/home/magnus|$HOME|g" "$WORKTREE_DIR"/*
fi

echo "==> [4/4] Import memory -> $MEM_DIR"
if [ -d "$MEM_DIR" ]; then
  echo "    đã có memory cũ tại $MEM_DIR -> bỏ qua (giữ dữ liệu hiện tại)"
else
  mkdir -p "$MEM_DIR"
  cp -r "$REPO_DIR/memory/." "$MEM_DIR/"
  echo "    đã import memory (profile + kiến thức dự án)"
fi

echo ""
echo "==> Xong! Mở 'opencode' lần đầu: plugins npm sẽ được cài tự động."
echo "    MCP playwright cần browser: npx playwright install chromium"
