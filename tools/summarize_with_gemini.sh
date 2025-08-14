#!/usr/bin/env bash
set -euo pipefail
RAW="${1:?Usage: summarize_with_gemini.sh <raw_context.md>}"
OUT="${2:-/tmp/context-capsule.md}"

read -r -d '' SYS <<'PROMPT'
You compress software change context into a concise "Context Capsule" for Claude Code.
Goals:
- Keep <= 2k tokens; focus on objective, diffs, rules, ADR constraints, and error gist.
- Remove repetition and irrelevant lines.
- Output exactly in the requested markdown schema.
PROMPT

read -r -d '' USR <<'PROMPT'
Build a Context Capsule with this schema:

# Context Capsule (for Claude Code)
- Repo: virtual-marketing-team
- Mode: (PR-REVIEW|BLOCKER-QA)
- Author: (if available)
- Time: (ISO8601)

## Objective
(2-3 lines)

## Change/Issue Summary (<=10 lines)

## Key Diffs (trimmed)
```diff
(critical hunks only)
Constraints & Rules (from .cursor/rules)
bullets (3-6)

ADR Snapshot
bullets (1-3 decisions + constraints)

Error/Log (top-k)
(up to 10 lines)
PROMPT

↓↓↓ 여기의 gemini 호출 부분을 실제 CLI에 맞게 바꾸세요 ↓↓↓
CAPSULE=$(gemini --model gemini-1.5-pro --system "$SYS" --input "$(cat "$RAW")" --user "$USR")
printf "%s\n" "$CAPSULE" > "$OUT"
echo "$OUT"
