from pathlib import Path

path = Path('lib/features/dashboard/view/feedback_page.dart')
text = path.read_text(encoding='utf-8')
stack = []
openers = {'(': ')', '[': ']', '{': '}'}
closers = {')': '(', ']': '[', '}': '{'}
for idx, ch in enumerate(text, start=1):
    if ch in openers:
        stack.append((ch, idx))
    elif ch in closers:
        if not stack:
            print('unmatched closer', ch, idx)
            break
        opener, op_idx = stack.pop()
        if opener != closers[ch]:
            print('mismatch', opener, op_idx, 'vs', ch, idx)
            print('stack tail at mismatch:', stack[-20:])
            break
else:
    if stack:
        print('unmatched openers', stack[-20:])
    else:
        print('all balanced')
