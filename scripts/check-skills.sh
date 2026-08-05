#!/usr/bin/env bash
# ============================================================
# check-skills.sh — Arisa's Watchdog 💜
# So baseline hash của ~/.agents/skills, báo file mới/đổi/xoá
# + đối chiếu .skill-lock.json (phát hiện skill "nguồn lạ").
# Dùng: check-skills.sh [--update]   (--update = cập nhật baseline mới)
# ============================================================
set -u

BASE_DIR="$HOME/.agents"
SKILLS_DIR="$BASE_DIR/skills"
LOCK="$BASE_DIR/.skill-lock.json"
BASELINE="$BASE_DIR/.skill-baseline.sha1"
TMP="$(mktemp)"

RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'; CY=$'\033[36m'; RST=$'\033[0m'; BOLD=$'\033[1m'

[ -d "$SKILLS_DIR" ] || { echo "❌ Không thấy $SKILLS_DIR"; exit 1; }

# tạo danh sách hash hiện tại
find "$SKILLS_DIR" -type f | sort | while read -r f; do
  sha1sum "$f"
done > "$TMP"

if [ "${1:-}" = "--update" ] || [ ! -f "$BASELINE" ]; then
  mv "$TMP" "$BASELINE"
  echo "${GRN}✅ Baseline đã tạo/cập nhật: $BASELINE (${BOLD}$(wc -l < "$BASELINE") file${RST}${GRN})${RST}"
  exit 0
fi

echo "${BOLD}${CY}👁️  Watchdog: so sánh skills với baseline...${RST}"
A=0; M=0; D=0

# file mới (A) hoặc thay đổi (M)
while read -r hash path; do
  [ -z "$path" ] && continue
  old=$(grep -F "  $path" "$BASELINE" 2>/dev/null | awk '{print $1}')
  if [ -z "$old" ]; then
    echo "  ${YEL}[MỚI]${RST} $path"
    A=$((A+1))
  elif [ "$old" != "$hash" ]; then
    echo "  ${YEL}[ĐỔI]${RST} $path"
    M=$((M+1))
  fi
done < "$TMP"

# file bị xoá (D)
while read -r _oldhash path; do
  [ -z "$path" ] && continue
  if ! grep -qF "  $path" "$TMP" 2>/dev/null; then
    echo "  ${RED}[XOÁ]${RST} $path"
    D=$((D+1))
  fi
done < "$BASELINE"

# đối chiếu skill-lock: skill không có trong lock = nguồn lạ (trừ khi đã xác nhận trong approved list)
echo ""
echo "${BOLD}─ Đối chiếu nguồn gốc (.skill-lock.json + .skill-approved)${RST}"
LOCKED_SKILLS=""
if [ -f "$LOCK" ]; then
  LOCKED_SKILLS=$(grep -o '"skillPath":[[:space:]]*"[^"]*"' "$LOCK" 2>/dev/null | sed 's/.*: *"//;s/"//')
fi
APPROVED="$BASE_DIR/.skill-approved"
UNKNOWN=0
for d in "$SKILLS_DIR"/*/; do
  [ -d "$d" ] || continue
  name=$(basename "$d")
  if ! echo "$LOCKED_SKILLS" | grep -qF "$name"; then
    if [ -f "$APPROVED" ] && grep -qxF "$name" "$APPROVED"; then
      continue  # skill cũ đã được xác nhận an toàn
    fi
    echo "  ${RED}[NGUỒN LẠ]${RST} $name (không có trong skill-lock và chưa xác nhận!)"
    UNKNOWN=$((UNKNOWN+1))
  fi
done
[ "$UNKNOWN" -eq 0 ] && echo "  ${GRN}Tất cả skill đều có nguồn gốc rõ ràng ✅${RST}"
echo "  ${CY}(skill trong .skill-approved không báo lạ — xem danh sách: cat ~/.agents/.skill-approved)${RST}"

echo ""
echo "${BOLD}══════════════════════════════════════════${RST}"
echo "  Mới: $A | Đổi: $M | Xoá: $D | Nguồn lạ: $UNKNOWN"
if [ $((A+M+D+UNKNOWN)) -eq 0 ]; then
  echo "  ${GRN}✅ Không có thay đổi — skills sạch như lúc baseline.${RST}"
else
  echo "  ${YEL}⚠️  Có thay đổi — nếu đây là do anh/em cài skill mới, chạy: check-skills.sh --update${RST}"
fi
echo "${BOLD}══════════════════════════════════════════${RST}"

rm -f "$TMP"
