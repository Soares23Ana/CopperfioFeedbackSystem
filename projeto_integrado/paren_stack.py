from pathlib import Path

path = Path('lib/features/dashboard/view/feedback_page.dart')
text = path.read_text(encoding='utf-8')
stack = []
line = 1
i = 0
in_single = False
in_double = False
in_triple = False
escaped = False
while i < len(text):
    ch = text[i]
    if ch == '\n':
        line += 1
        escaped = False
        in_single = False
        in_double = False
    if in_single or in_double:
        if escaped:
            escaped = False
        elif ch == '\\':
            escaped = True
        elif in_single and ch == "'":
            in_single = False
        elif in_double and ch == '"':
            in_double = False
    else:
        if ch == "'":
            in_single = True
        elif ch == '"':
            in_double = True
        elif ch == '/' and i + 1 < len(text) and text[i+1] == '/':
            while i < len(text) and text[i] != '\n':
                i += 1
            continue
        elif ch == '/' and i + 1 < len(text) and text[i+1] == '*':
            i += 2
            while i + 1 < len(text) and not (text[i] == '*' and text[i+1] == '/'):
                if text[i] == '\n':
                    line += 1
                i += 1
            i += 1
        elif ch == '(':
            stack.append((line, i, text[max(0, i-40):i+40]))
        elif ch == ')':
            if stack:
                stack.pop()
            else:
                print('extra close ) at line', line)
    i += 1

print('stack length', len(stack))
for entry in stack[-5:]:
    print('unmatched open ( at line', entry[0], 'context:', repr(entry[2]))
