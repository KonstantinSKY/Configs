#!/usr/bin/env bash
# Claude Code status line: model | limits | ctx

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Model
parts="$model"

# Rate limits
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -n "$five" ] || [ -n "$week" ]; then
  rate_str="lim:"
  [ -n "$five" ] && rate_str="$rate_str 5h:$(printf '%.0f' "$five")%"
  [ -n "$week" ] && rate_str="$rate_str 7d:$(printf '%.0f' "$week")%"
  parts="$parts | $rate_str"
fi

# Context
if [ -n "$remaining_pct" ]; then
  remaining_int=$(printf '%.0f' "$remaining_pct")
  parts="$parts | ctx: ${remaining_int}% left"
fi

printf "%s" "$parts"
