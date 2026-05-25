#!/usr/bin/env bash
# extract-audit-tails.sh — 解析 PR 历史 comment 里的 audit 尾巴
#
# 目的:给增量机制用 —— LLM 拿到"上次跑了什么"的结构化记录,决定增量 vs full review。
# 脚本只做 deterministic 解析(grep + parse),不做判断。
#
# 用法:bash extract-audit-tails.sh <PR-number>
# 输出:每行一条 audit 记录,格式:
#   <comment-timestamp>|<audit-tail-content>
# 若 PR 无 audit 尾巴 → 输出 "no-audit-tails" + exit 0(不算错误)

set -euo pipefail

PR_NUMBER="${1:?Usage: $0 <PR-number>}"

# 拿全部 PR comment(含 timestamp 和 body)
comments_json=$(gh pr view "$PR_NUMBER" --json comments 2>/dev/null || echo '{"comments":[]}')

# parse 出 audit 尾巴
# audit 尾巴形如:<!-- audit: file=foo, ripple=A-backward, dna=A14, severity=yellow -->
found_any=0
echo "$comments_json" | python3 -c "
import json, sys, re

data = json.load(sys.stdin)
pattern = re.compile(r'<!-- audit:\s*([^>]+?)\s*-->')

for c in data.get('comments', []):
    timestamp = c.get('createdAt', 'unknown')
    body = c.get('body', '')
    matches = pattern.findall(body)
    for m in matches:
        print(f'{timestamp}|{m.strip()}')
" || true

# 如果没匹配到,output sentinel
if ! gh pr view "$PR_NUMBER" --json comments --jq '.comments[].body' 2>/dev/null \
     | grep -q '<!-- audit:'; then
  echo "no-audit-tails"
fi

# 顺带打印距上次跑的天数(给增量决策用)
# 找最近一条 audit 尾巴的 timestamp,算到现在多少天
last_audit_ts=$(echo "$comments_json" | python3 -c "
import json, sys, re
data = json.load(sys.stdin)
pattern = re.compile(r'<!-- audit:')
last = None
for c in data.get('comments', []):
    if pattern.search(c.get('body', '')):
        last = c.get('createdAt')
if last: print(last)
" 2>/dev/null || echo "")

if [[ -n "$last_audit_ts" ]]; then
  # 计算天数差(macOS / Linux 兼容)
  if date --version >/dev/null 2>&1; then
    # GNU date (Linux)
    days_ago=$(( ( $(date +%s) - $(date -d "$last_audit_ts" +%s) ) / 86400 ))
  else
    # BSD date (macOS)
    days_ago=$(( ( $(date +%s) - $(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_audit_ts" +%s 2>/dev/null || echo 0) ) / 86400 ))
  fi
  echo "---DAYS-SINCE-LAST-AUDIT:${days_ago}---"
fi
