#!/usr/bin/env bash
set -euo pipefail
RAW="${1:?Usage: summarize_with_gemini.sh <raw.md>}"
OUT="${2:-/tmp/context-capsule.md}"
MODE="${3:-SPEC}"  # SPEC | PR-REVIEW | BLOCKER-QA

read -r -d '' SYS <<'PROMPT'
Compress software planning/changes into a concise "Context Capsule" for Claude Code.
Keep it <= 2k tokens; include objective, key points/diffs, constraints (rules/ADR).
PROMPT

# 공통 스키마(모드만 다름)
read -r -d '' USR <<'PROMPT'
# Context Capsule (for Claude Code)
- Repo: virtual-marketing-team
- Mode: {{MODE}}
- Time: (UTC ISO8601)

## Objective
(2-3 lines)

## Key Points / Change Summary (<=10 lines)

## Key Diffs or Excerpts (trimmed)
```diff
(critical hunks only or N/A)
Constraints & Rules (.cursor/rules) / ADR Snapshot
bullets (1-6)
PROMPT

USR="${USR//'{{MODE}}'/$MODE}"

if command -v gemini >/dev/null 2>&1; then
CAPSULE=$(gemini --model gemini-1.5-pro --system "$SYS" --input "$(cat "$RAW")" --user "$USR")
printf "%s\n" "$CAPSULE" > "$OUT"
else
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
{
echo "# Context Capsule (for Claude Code)"
echo "- Repo: virtual-marketing-team"
echo "- Mode: $MODE"
echo "- Time: $NOW"
echo
echo "## Key Points / Change Summary (<=10 lines)"
sed -n '1,80p' "$RAW"
} > "$OUT"
fi
echo "$OUT"
