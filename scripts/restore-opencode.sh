#!/usr/bin/env bash
# ============================================================
# restore-opencode.sh — Arisa's Airbag (khôi phục) 💜
# Khôi phục opencode từ bản backup mới nhất (hoặc $1 = file cụ thể).
# ============================================================
set -euo pipefail

DEST_DIR="$HOME/.opencode-backups"

if [ "${1:-}" != "" ]; then
  SRC="$1"
else
  SRC="$(ls -1t "$DEST_DIR"/opencode-*.tar.zst 2>/dev/null | head -n1)"
fi

if [ -z "${SRC:-}" ] || [ ! -f "$SRC" ]; then
  echo "❌ Không tìm thấy bản backup nào trong $DEST_DIR"
  exit 1
fi

echo "📦 Khôi phục từ: $SRC"
tar --zstd -xf "$SRC" -C "$HOME"
echo "✅ Đã khôi phục!"
echo "⚠️  QUAN TRỌNG: thoát và mở lại opencode để áp dụng."
