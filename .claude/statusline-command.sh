#!/usr/bin/env bash
# Claude Code statusline — 3-line display with rate limit info

input=$(cat)

# ── ANSI colors (24-bit) ──────────────────────────────────────────────────────
RST="\033[0m"
DIM="\033[2m"
BOLD="\033[1m"

# palette
C_CYAN="\033[38;2;86;182;194m"      # #56B6C2
C_PURPLE="\033[38;2;198;120;221m"    # #C678DD
C_BLUE="\033[38;2;97;175;239m"      # #61AFEF
C_ORANGE="\033[38;2;209;154;102m"   # #D19A66
C_GREY="\033[38;2;92;99;112m"       # #5C6370
C_DARK="\033[38;2;55;62;72m"        # #373E48

# usage-level colors
color_for_pct() {
  local pct=$1
  if   [ "$pct" -ge 80 ]; then printf "\033[38;2;224;108;117m"   # red   #E06C75
  elif [ "$pct" -ge 50 ]; then printf "\033[38;2;229;192;123m"   # yellow #E5C07B
  else                          printf "\033[38;2;152;195;121m"   # green  #98C379
  fi
}

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
  diff_nums=$(git -C "$cwd" --no-optional-locks diff --numstat HEAD 2>/dev/null \
              | awk '{a+=$1; d+=$2} END{printf "+%d/-%d", a, d}')
  [ -n "$diff_nums" ] && diff_str="$diff_nums"
fi

# ── Parse rate-limit from stdin JSON (official statusline fields) ─────────────
fh_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // 0' | cut -d. -f1)
sd_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // 0' | cut -d. -f1)
fh_reset_epoch=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
sd_reset_epoch=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# ── Colored progress bar (20 segments) ───────────────────────────────────────
progress_bar() {
  local pct=$1
  local color=$2
  local width=20
  local filled=$(( pct * width / 100 ))
  local bar=""
  for i in $(seq 1 $width); do
    if [ "$i" -le "$filled" ]; then
      bar="${bar}${color}━${RST}"
    else
      bar="${bar}${C_DARK}─${RST}"
    fi
  done
  echo "$bar"
}

# ── Reset time formatting (Asia/Tokyo) ───────────────────────────────────────
format_reset_time() {
  local epoch=$1
  local fmt=$2
  if [ -z "$epoch" ] || [ "$epoch" = "null" ]; then echo ""; return; fi

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
    LC_ALL=en_US.UTF-8 TZ="Asia/Tokyo" date -j -r "$ts" "+%-I%p" 2>/dev/null | tr 'A-Z' 'a-z' || true
  else
    LC_ALL=en_US.UTF-8 TZ="Asia/Tokyo" date -j -r "$ts" "+%b %-d at %-I%p" 2>/dev/null | tr 'A-Z' 'a-z' || true
  fi
}

fh_reset_label=$(format_reset_time "$fh_reset_epoch" "time")
sd_reset_label=$(format_reset_time "$sd_reset_epoch" "datetime")

# ── Assemble lines ────────────────────────────────────────────────────────────
SEP=" ${C_GREY}·${RST} "

# Line 1: model · ctx% · diff · branch
line1="${C_PURPLE}${BOLD}${model_label}${RST}"
line1="${line1}${SEP}${C_GREY}ctx${RST} $(color_for_pct "$used_int")${ctx_str}${RST}"
[ -n "$diff_str" ] && line1="${line1}${SEP}${C_GREY}diff${RST} ${C_ORANGE}${diff_str}${RST}"
[ -n "$git_branch" ] && line1="${line1}${SEP}${C_GREY}on${RST} ${C_CYAN}${git_branch}${RST}"

# Line 2: 5h rate limit
fh_color=$(color_for_pct "$fh_pct")
fh_bar=$(progress_bar "$fh_pct" "$fh_color")
line2="${C_GREY}5h${RST} ${fh_bar} ${fh_color}${fh_pct}%${RST}"
[ -n "$fh_reset_label" ] && line2="${line2} ${DIM}reset ${fh_reset_label}${RST}"

# Line 3: 7d rate limit
sd_color=$(color_for_pct "$sd_pct")
sd_bar=$(progress_bar "$sd_pct" "$sd_color")
line3="${C_GREY}7d${RST} ${sd_bar} ${sd_color}${sd_pct}%${RST}"
[ -n "$sd_reset_label" ] && line3="${line3} ${DIM}reset ${sd_reset_label}${RST}"

printf "%b\n%b\n%b\n" "$line1" "$line2" "$line3"
