
### Claude Code token usage & cost estimator
function claude-cost () {
  local target_date=${1:-$(TZ=Asia/Tokyo date -j -v-1d '+%Y-%m-%d' 2>/dev/null || TZ=Asia/Tokyo date -d '1 day ago' '+%Y-%m-%d')}

  python3 -c "
import json, os, glob
from datetime import datetime, timezone, timedelta

JST = timezone(timedelta(hours=9))
target_date = '$target_date'

input_tokens = 0
output_tokens = 0
cache_read = 0
cache_creation = 0

for fpath in glob.glob(os.path.expanduser('~/.claude/projects/**/*.jsonl'), recursive=True):
    try:
        with open(fpath) as f:
            for line in f:
                try:
                    obj = json.loads(line)
                    if obj.get('type') != 'assistant':
                        continue
                    ts = obj.get('timestamp')
                    if not ts:
                        continue
                    dt = datetime.fromisoformat(ts.replace('Z', '+00:00')).astimezone(JST)
                    if dt.strftime('%Y-%m-%d') != target_date:
                        continue
                    usage = obj.get('message', {}).get('usage', {})
                    if usage:
                        input_tokens += usage.get('input_tokens', 0)
                        output_tokens += usage.get('output_tokens', 0)
                        cache_read += usage.get('cache_read_input_tokens', 0)
                        cache_creation += usage.get('cache_creation_input_tokens', 0)
                except:
                    pass
    except:
        pass

input_cost = input_tokens * 3 / 1_000_000
output_cost = output_tokens * 15 / 1_000_000
cache_read_cost = cache_read * 0.30 / 1_000_000
cache_creation_cost = cache_creation * 3.75 / 1_000_000
total = input_cost + output_cost + cache_read_cost + cache_creation_cost

print(f'=== {target_date} (JST) Claude Code 使用量 ===')
print(f'Input tokens:          {input_tokens:>12,}  (est. \${input_cost:.4f})')
print(f'Output tokens:         {output_tokens:>12,}  (est. \${output_cost:.4f})')
print(f'Cache read tokens:     {cache_read:>12,}  (est. \${cache_read_cost:.4f})')
print(f'Cache creation tokens: {cache_creation:>12,}  (est. \${cache_creation_cost:.4f})')
print(f'---')
print(f'合計 (概算):                           \${total:.4f} USD')
print(f'                                       ¥{total*150:.0f} (1USD=150円換算)')
"
}
