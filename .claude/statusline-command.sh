#!/usr/bin/env bash
# Claude Code statusline — 3-line display with rate limit info

input=$(cat)

# ── ANSI colors (24-bit) ──────────────────────────────────────────────────────
C_RESET="\033[0m"
# usage-level colors
color_for_pct() {
  local pct=$1
  if   [ "$pct" -ge 80 ]; then printf "\033[38;2;224;108;117m"   # red   #E06C75
  elif [ "$pct" -ge 50 ]; then printf "\033[38;2;229;192;123m"   # yellow #E5C07B
  else                          printf "\033[38;2;151;201;195m"   # green  #97C9C3
  fi
}
C_SEP="\033[38;2;74;88;92m"   # grey #4A585C

# ── Extract fields from stdin JSON ───────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model_id=$(echo "$input" | jq -r '.model.id // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Map model ID → short display name
case "$model_id" in
  claude-opus-4*)    model_label="Opus 4" ;;
  claude-sonnet-4*)  model_label="Sonnet 4" ;;
  claude-haiku-4*)   model_label="Haiku 4" ;;
  claude-opus-3*)    model_label="Opus 3" ;;
  claude-sonnet-3*)  model_label="Sonnet 3" ;;
  claude-haiku-3*)   model_label="Haiku 3" ;;
  "")                model_label="Claude" ;;
  *)                 model_label="$model_id" ;;
esac

# Append version suffix from model ID (e.g. "-4-6" → "4.6")
version_suffix=$(echo "$model_id" | grep -oE '[0-9]+-[0-9]+$' | tr '-' '.')
[ -n "$version_suffix" ] && model_label="${model_label} ${version_suffix}"

# ── Context window percentage ─────────────────────────────────────────────────
used_int=0
ctx_str=""
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
  used_int=${used_pct%.*}
  ctx_str="${used_int}%"
fi

# ── Git branch + diff stat ────────────────────────────────────────────────────
git_branch=""
diff_str=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
               || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  # Lines added/deleted vs HEAD (index + working tree combined)
  diff_nums=$(git -C "$cwd" --no-optional-locks diff --numstat HEAD 2>/dev/null \
              | awk '{a+=$1; d+=$2} END{printf "+%d/-%d", a, d}')
  [ -n "$diff_nums" ] && diff_str="$diff_nums"
fi

# ── Rate limit cache / fetch ──────────────────────────────────────────────────
CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_TTL=360

fetch_usage() {
  # Retrieve OAuth token from macOS Keychain
  local token
  token=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null \
          | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('oauthToken',''))" 2>/dev/null \
          || true)
  [ -z "$token" ] && return 1

  curl -sf -m 10 \
    -H "Authorization: Bearer ${token}" \
    -H "anthropic-version: 2023-06-01" \
    "https://api.anthropic.com/api/oauth/usage" > "$CACHE_FILE" 2>/dev/null
}

usage_json=""
if [ -f "$CACHE_FILE" ]; then
  now=$(date +%s)
  mtime=$(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
  age=$(( now - mtime ))
  if [ "$age" -lt "$CACHE_TTL" ]; then
    usage_json=$(cat "$CACHE_FILE")
  fi
fi

if [ -z "$usage_json" ]; then
  fetch_usage && usage_json=$(cat "$CACHE_FILE" 2>/dev/null) || true
fi

# ── Parse rate-limit utilization ─────────────────────────────────────────────
fh_pct=0
sd_pct=0
fh_reset_epoch=""
sd_reset_epoch=""

if [ -n "$usage_json" ]; then
  fh_pct=$(echo "$usage_json" | jq -r '.five_hour.utilization // 0' | awk '{printf "%d", $1*100}')
  sd_pct=$(echo "$usage_json" | jq -r '.seven_day.utilization // 0' | awk '{printf "%d", $1*100}')
  fh_reset_epoch=$(echo "$usage_json" | jq -r '.five_hour.reset_at // empty' 2>/dev/null || true)
  sd_reset_epoch=$(echo "$usage_json" | jq -r '.seven_day.reset_at // empty' 2>/dev/null || true)
fi

# ── Progress bar (10 segments) ────────────────────────────────────────────────
progress_bar() {
  local pct=$1
  local filled=$(( pct / 10 ))
  local bar=""
  for i in $(seq 1 10); do
    if [ "$i" -le "$filled" ]; then bar="${bar}▰"; else bar="${bar}▱"; fi
  done
  echo "$bar"
}

# ── Reset time formatting (Asia/Tokyo) ───────────────────────────────────────
format_reset_time() {
  local epoch=$1
  local fmt=$2   # "time" → "4pm"  |  "datetime" → "Mar 6 at 1pm"
  if [ -z "$epoch" ] || [ "$epoch" = "null" ]; then echo ""; return; fi

  # epoch may be ISO8601 string or unix timestamp
  local ts
  if echo "$epoch" | grep -qE '^[0-9]+$'; then
    ts=$epoch
  else
    ts=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%SZ" "$epoch" "+%s" 2>/dev/null \
         || python3 -c "import sys,datetime,calendar; s=sys.argv[1].rstrip('Z'); dt=datetime.datetime.fromisoformat(s); print(calendar.timegm(dt.timetuple()))" "$epoch" 2>/dev/null \
         || echo "")
  fi
  [ -z "$ts" ] && return

  if [ "$fmt" = "time" ]; then
    TZ="Asia/Tokyo" date -j -r "$ts" "+%-I%p" 2>/dev/null | tr 'A-Z' 'a-z' || true
  else
    TZ="Asia/Tokyo" date -j -r "$ts" "+%b %-d at %-I%p" 2>/dev/null | sed 's/AM/am/;s/PM/pm/' || true
  fi
}

fh_reset_label=$(format_reset_time "$fh_reset_epoch" "time")
sd_reset_label=$(format_reset_time "$sd_reset_epoch" "datetime")

# ── Assemble lines ────────────────────────────────────────────────────────────
SEP="${C_SEP} │ ${C_RESET}"

# Line 1: model │ ctx% │ diff │ branch
line1=""
model_c="$(color_for_pct 0)🤖 ${model_label}${C_RESET}"
ctx_c="$(color_for_pct "$used_int")📊 ${ctx_str}${C_RESET}"
line1="${model_c}${SEP}${ctx_c}"
[ -n "$diff_str" ]    && line1="${line1}${SEP}$(color_for_pct 0)✏️  ${diff_str}${C_RESET}"
[ -n "$git_branch" ]  && line1="${line1}${SEP}$(color_for_pct 0)🔀 ${git_branch}${C_RESET}"

# Line 2: 5h rate limit
fh_bar=$(progress_bar "$fh_pct")
fh_color=$(color_for_pct "$fh_pct")
line2="${fh_color}⏱ 5h  ${fh_bar}  ${fh_pct}%${C_RESET}"
[ -n "$fh_reset_label" ] && line2="${line2}  Resets ${fh_reset_label} (Asia/Tokyo)"

# Line 3: 7d rate limit
sd_bar=$(progress_bar "$sd_pct")
sd_color=$(color_for_pct "$sd_pct")
line3="${sd_color}📅 7d  ${sd_bar}  ${sd_pct}%${C_RESET}"
[ -n "$sd_reset_label" ] && line3="${line3}  Resets ${sd_reset_label} (Asia/Tokyo)"

printf "%b\n%b\n%b\n" "$line1" "$line2" "$line3"
