from pathlib import Path
from itertools import accumulate

path = Path('lib/features/dashboard/view/feedback_page.dart')
text = path.read_text(encoding='utf-8')
lines = text.splitlines()
paren = 0
max_balance = 0
max_line = 0
for i, line in enumerate(lines, 1):
    delta = line.count('(') - line.count(')')
    if delta != 0:
        print(f'{i:4d} {delta:+d} {paren+delta:3d} {line}')
    paren += delta
    if paren > max_balance:
        max_balance = paren
        max_line = i
print('final balance', paren)
print('max balance', max_balance, 'at line', max_line)