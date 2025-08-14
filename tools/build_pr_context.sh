#!/usr/bin/env bash
set -euo pipefail
PR_NUMBER="${1:?Usage: build_pr_context.sh <PR_NUMBER>}"
OUT="${2:-/tmp/pr_context_raw.md}"

TITLE=$(gh pr view "$PR_NUMBER" --json title -q .title 2>/dev/null || echo "")
BODY=$(gh pr view "$PR_NUMBER" --json body  -q .body  2>/dev/null || echo "")
DIFF=$(gh pr diff "$PR_NUMBER" --patch | sed -E 's/[[:cntrl:]]//g' | head -n 800)

RULES_SNIP=$( [ -d .cursor/rules ] && sed -n '1,150p' .cursor/rules/*.md 2>/dev/null | head -n 150 )
ADR_SNIP=$( [ -d docs/adr ] && sed -n '1,150p' docs/adr/*.md 2>/dev/null | head -n 150 )

cat > "$OUT" <<MD
# PR RAW CONTEXT
Title: $TITLE

## PR Body
$BODY

## Diff (trimmed)
\`\`\`diff
$DIFF
\`\`\`

## Rules (snippets)
$RULES_SNIP

## ADR (snippets)
$ADR_SNIP
MD

echo "$OUT"
