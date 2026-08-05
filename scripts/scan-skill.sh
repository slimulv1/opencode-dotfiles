#!/usr/bin/env bash
# ============================================================
# scan-skill.sh — Arisa's Vaccine 💜 (phiên bản nhanh)
# Quét skill/plugin tìm dấu hiệu mã độc.
# Dùng: scan-skill.sh <thư-mục> [thư-mục...] | scan-skill.sh --all
# Kết quả: PASS (an toàn) / WARN (nghi ngờ) / DANGER (nguy hiểm)
# ============================================================
set -u

RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'; BLU=$'\033[36m'; RST=$'\033[0m'; BOLD=$'\033[1m'

# ---- DANGER: phá hoại / ransomware / tự xoá hệ thống / pipe curl vào shell ----
DANGER_RE='rm[[:space:]]+-rf[[:space:]]+(/|/\*|~[[:space:]]*$)|mkfs\.[a-z0-9]+|dd[[:space:]]+if=|fdisk[[:space:]]+/(dev|sd|nvme)|:\(\)\{[[:space:]]*\|[[:space:]]*\|?[[:space:]]*&|openssl[[:space:]]+enc|from[[:space:]]+cryptography[[:space:]]+import[[:space:]]+Fernet|encrypt_files\(|(curl|wget)[[:space:]]+[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba)?sh|(ba)?sh[[:space:]]+<\([[:space:]]*(curl|wget)'

# ---- WARN: exfil / C2 / ẩn giấu / ghi vào nơi nhạy cảm ----
WARN_RE='base64[[:space:]]+-d|(^|[^A-Za-z])ncat([^A-Za-z]|$)|socat[[:space:]]+TCP|curl[[:space:]]+-X[[:space:]]+POST|curl[[:space:]]+-d[[:space:]]|~/\.ssh|authorized_keys|/etc/passwd|/etc/sudoers|/etc/rc\.local|chmod[[:space:]]+777[[:space:]]+/|crontab|systemctl[[:space:]]+enable|\.config/autostart|eval[[:space:]]+\$|wget[[:space:]]+-O[[:space:]]+/dev/null|git[[:space:]]+clone[[:space:]].*\|[[:space:]]*(ba)?sh|pip[[:space:]]+install[[:space:]].*--user|npm[[:space:]]+install[[:space:]]-g'

TOTAL_DANGER=0
TOTAL_WARN=0
SCANNED=0

scan_file() {
  local f="$1" rel="$2" hits
  # 1 pass DANGER (bỏ dòng comment, bỏ file nhị phân)
  hits=$(grep -nIE "$DANGER_RE" "$f" 2>/dev/null | grep -vE '^[0-9]+:[[:space:]]*#' || true)
  if [ -n "$hits" ]; then
    while IFS= read -r l; do
      printf '%s[%s]DANGER%s %s:%s\n' "$RED" '!!' "$RST" "$rel" "$l"
    done <<< "$hits"
    TOTAL_DANGER=$((TOTAL_DANGER + $(grep -c . <<< "$hits")))
  fi
  # 1 pass WARN
  hits=$(grep -nIE "$WARN_RE" "$f" 2>/dev/null | grep -vE '^[0-9]+:[[:space:]]*#' || true)
  if [ -n "$hits" ]; then
    while IFS= read -r l; do
      printf '%s[!]%s %s:%s\n' "$YEL" "$RST" "$rel" "$l"
    done <<< "$hits"
    TOTAL_WARN=$((TOTAL_WARN + $(grep -c . <<< "$hits")))
  fi
  SCANNED=$((SCANNED+1))
}

targets=()
if [ "${1:-}" = "--all" ]; then
  targets=( "$HOME/.agents/skills" "$HOME/.claude/skills" "$HOME/.config/opencode/skills" "$HOME/.config/opencode/plugins" )
else
  targets=( "$@" )
fi
[ ${#targets[@]} -eq 0 ] && { echo "Dùng: scan-skill.sh <thư-mục> [thư-mục...] | scan-skill.sh --all"; exit 2; }

echo "${BOLD}${BLU}🔍 Arisa Vaccine — quét ${#targets[@]} vùng...${RST}"

for dir in "${targets[@]}"; do
  [ -d "$dir" ] || { echo "  (bỏ qua: $dir không tồn tại)"; continue; }
  echo "${BOLD}── $dir${RST}"
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    case "$f" in
      *.md|*.sh|*.py|*.js|*.mjs|*.cjs|*.ts|*.tsx|*.jsx|*.fish|*.pl|*.rb|*.lua|*.bash) ;;
      *) continue ;;
    esac
    [ "$(basename "$f")" = "scan-skill.sh" ] && continue
    scan_file "$f" "${f#"$HOME"/}"
  done < <(find "$dir" -type f 2>/dev/null | grep -vE '/(node_modules|vendor)/|\.min\.(js|mjs|cjs)$')
done

echo ""
echo "${BOLD}══════════════════════════════════════════${RST}"
echo "  Đã quét: $SCANNED file"
if [ "$TOTAL_DANGER" -gt 0 ]; then
  echo "  ${RED}DANGER: $TOTAL_DANGER ⛔ — phát hiện mã nguy hiểm!${RST}"
elif [ "$TOTAL_WARN" -gt 0 ]; then
  echo "  ${YEL}WARN: $TOTAL_WARN ⚠️ — có dấu hiệu nghi ngờ, xem chi tiết bên trên${RST}"
else
  echo "  ${GRN}PASS ✅ — sạch, không có dấu hiệu nguy hiểm${RST}"
fi
echo "${BOLD}══════════════════════════════════════════${RST}"
[ "$TOTAL_DANGER" -gt 0 ] && exit 1 || exit 0
