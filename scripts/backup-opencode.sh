#!/usr/bin/env bash
# ============================================================
# backup-opencode.sh — Arisa's Airbag 💜
# Backup toàn bộ cấu hình opencode + skills + plugins.
# → ~/.opencode-backups/opencode-YYYYMMDD-HHMMSS.tar.zst (giữ 10 bản mới nhất)
# ============================================================
set -euo pipefail

DEST_DIR="$HOME/.opencode-backups"
STAMP="$(date +%Y%m%d-%H%M%S)"
DEST="$DEST_DIR/opencode-$STAMP.tar.zst"

mkdir -p "$DEST_DIR"

# backup các vùng cấu hình opencode + skills (bỏ node_modules, rác)
tar --zstd -cf "$DEST" \
  -C "$HOME" \
  --exclude='node_modules' \
  --exclude='.git' \
  .config/opencode \
  .agents/skills \
  .agents/.skill-lock.json \
  .claude/skills \
  .opencode 2>/dev/null || true

# giữ 10 bản mới nhất
ls -1t "$DEST_DIR"/opencode-*.tar.zst 2>/dev/null | tail -n +11 | while read -r old; do
  rm -f "$old"
done

SIZE=$(du -h "$DEST" | cut -f1)
echo "✅ Backup xong: $DEST ($SIZE)"
echo "   Còn $(ls -1 "$DEST_DIR"/opencode-*.tar.zst 2>/dev/null | wc -l) bản backup."
