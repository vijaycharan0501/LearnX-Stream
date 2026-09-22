import os
import re

lib_dir = r'c:\Users\vijay\OneDrive\Desktop\WebSites\LearnX Stream\Website LearnX stream\learnx_stream\lib'

matches = []
for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8', errors='ignore') as fp:
                content = fp.read()
                # Find any EdgeInsets containing 15 or 11
                for line_no, line in enumerate(content.splitlines(), 1):
                    if 'EdgeInsets' in line and ('15' in line or '11' in line):
                        matches.append(f"{f}:{line_no}: {line.strip()}")

print(f"Found {len(matches)} matches:")
for m in matches[:50]:
    print(m)
