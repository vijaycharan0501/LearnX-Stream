import os
import re

lib_dir = r'c:\Users\vijay\OneDrive\Desktop\WebSites\LearnX Stream\Website LearnX stream\learnx_stream\lib'

matches = []
for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8', errors='ignore') as fp:
                lines = fp.readlines()
                for i, line in enumerate(lines, 1):
                    if 'MainAxisSize.min' in line or 'mainAxisSize: min' in line:
                        matches.append((f, i, line.strip()))

print(f"Total Rows/Columns with MainAxisSize.min: {len(matches)}")
for m in matches:
    print(f"{m[0]}:{m[1]}: {m[2]}")
