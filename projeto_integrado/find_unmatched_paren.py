from pathlib import Path

path = Path('lib/features/dashboard/view/feedback_page.dart')
text = path.read_text(encoding='utf-8')
lines = text.splitlines()
paren = 0
max_bal = -999
max_line = None
for i, line in enumerate(lines, 1):
    delta = line.count('(') - line.count(')')
    paren += delta
    if paren > max_bal:
        max_bal = paren
        max_line = i
print('final paren balance:', paren)
print('max balance:', max_bal, 'at line', max_line)
print('line content:', repr(lines[max_line-1]))
print('--- surrounding lines ---')
for j in range(max(1, max_line-4), min(len(lines), max_line+4)+1):
    print(f'{j}: {lines[j-1]}')
