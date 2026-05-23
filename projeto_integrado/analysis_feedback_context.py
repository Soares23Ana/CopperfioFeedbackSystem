from pathlib import Path

path = Path('lib/features/dashboard/view/feedback_page.dart')
text = path.read_text(encoding='utf-8')
position = 29126
line = text.count('\n', 0, position) + 1
col = position - text.rfind('\n', 0, position)
print('position', position, 'line', line, 'col', col)
start = text.rfind('\n', 0, position) + 1
end = text.find('\n', position)
if end == -1:
    end = len(text)
print('line text:', repr(text[start:end]))
print('previous line:', repr(text[text.rfind('\n', 0, start-1)+1:start]))
