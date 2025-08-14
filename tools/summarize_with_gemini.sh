#!/usr/bin/env bash
set -euo pipefail
RAW="${1:?Usage: summarize_with_gemini.sh <raw_context.md>}"
OUT="${2:-/tmp/context-capsule.md}"

read -r -d '' SYS <<'PROMPT'
You compress software change context into a concise "Context Capsule" for Claude Code.
Keep <= 2k tokens; focus on objective, diffs, rules, ADR constraints, error gist.
Remove repetition and noise. Output exactly in the requested markdown schema.
PROMPT

read -r -d '' USR <<'PROMPT'
# Context Capsule (for Claude Code)
- Repo: virtual-marketing-team
- Mode: PR-REVIEW
- Time: (UTC ISO8601)

## Objective
(2-3 lines)

## Change/Issue Summary (<=10 lines)

## Key Diffs (trimmed)
```diff
(critical hunks only)
Constraints & Rules (.cursor/rules)
bullets (3-6)

ADR Snapshot
bullets (1-3)

Error/Log (top-k)
(up to 10 lines)
PROMPT

if command -v gemini >/dev/null 2>&1; then
CAPSULE=$(gemini --model gemini-1.5-pro --system "$SYS" --input "$(cat "$RAW")" --user "$USR")
printf "%s\n" "$CAPSULE" > "$OUT"
else

Fallback: Gemini 미탑재 시 최소 캡슐 생성
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
{
echo "# Context Capsule (for Claude Code)"
echo "- Repo: virtual-marketing-team"
echo "- Mode: PR-REVIEW"
echo "- Time: $NOW"
echo
echo "## Change/Issue Summary (<=10 lines)"
sed -n '1,80p' "$RAW"
echo
echo "## Key Diffs (trimmed)"
echo 'diff'; sed -n '/^diff/,//p' "$RAW" | head -n 120; echo ''
} > "$OUT"
fi
echo "$OUT"
