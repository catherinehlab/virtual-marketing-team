#!/usr/bin/env bash
set -euo pipefail
PR_NUMBER="${1:?Usage: build_pr_context.sh <PR_NUMBER>}"
REPO_DIR="${2:-.}"
OUT="${3:-/tmp/pr_context_raw.md}"
cd "$REPO_DIR"
TITLE=$(gh pr view "$PR_NUMBER" --json title -q .title)
BODY=$(gh pr view "$PR_NUMBER" --json body -q .body)
DIFF=$(gh pr diff "$PR_NUMBER" --patch | sed -E 's/[[:cntrl:]]//g' | head -n 800)
FILES=$(gh pr view "$PR_NUMBER" --json files -q '.files[].path' | tr '\n' ' ')
RULES_SNIP=$( [ -d .cursor/rules ] && sed -n '1,120p' .cursor/rules/.md 2>/dev/null | head -n 200 )
ADR_SNIP=$( [ -d docs/adr ] && sed -n '1,120p' docs/adr/.md 2>/dev/null | head -n 200 )
cat > "$OUT" <<EOF2

PR RAW CONTEXT

Title: $TITLE

PR Body

$BODY

Diff (trimmed)

```diff
$DIFF
```

Rules (snippets)

$RULES_SNIP

ADR (snippets)

$ADR_SNIP
EOF2
echo "$OUT"
