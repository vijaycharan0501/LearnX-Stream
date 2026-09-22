import os
import re

dir_path = r'c:\Users\vijay\OneDrive\Desktop\WebSites\LearnX Stream\Website LearnX stream\learnx_stream\lib\features\smart_explain'

for root, dirs, files in os.walk(dir_path):
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8', errors='ignore') as fp:
                lines = fp.readlines()
                for i, line in enumerate(lines, 1):
                    if 'Button' in line:
                        print(f"{f}:{i}: {line.strip()}")
