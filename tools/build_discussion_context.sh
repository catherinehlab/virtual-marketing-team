#!/usr/bin/env bash
set -euo pipefail
DISC_NUM="${1:?Usage: build_discussion_context.sh <DISCUSSION_NUMBER>}"
OUT="${2:-/tmp/discussion_context_raw.md}"

DATA=$(gh api graphql -f query='
query($o:String!,$r:String!,$n:Int!){
repository(owner:$o, name:$r){
discussion(number:$n){ title body }
}}'
-F o="${GITHUB_REPOSITORY%/}" -F r="${GITHUB_REPOSITORY#/}" -F n="$DISC_NUM")

TITLE=$(echo "$DATA" | jq -r '.data.repository.discussion.title')
BODY=$(echo "$DATA" | jq -r '.data.repository.discussion.body')
RULES_SNIP=$( [ -d .cursor/rules ] && sed -n '1,120p' .cursor/rules/.md 2>/dev/null | head -n 200 )
ADR_SNIP=$( [ -d docs/adr ] && sed -n '1,120p' docs/adr/.md 2>/dev/null | head -n 200 )

cat > "$OUT" <<EOF2

DISCUSSION RAW CONTEXT

Title: $TITLE

Body

$BODY

Related Rules

$RULES_SNIP

Related ADR

$ADR_SNIP
EOF2
echo "$OUT"
