import os

dir_path = r'c:\Users\vijay\OneDrive\Desktop\WebSites\LearnX Stream\Website LearnX stream\learnx_stream\lib\features\smart_explain'

for root, dirs, files in os.walk(dir_path):
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8', errors='ignore') as fp:
                content = fp.read()
                if 'dispose' in content:
                    lines = content.splitlines()
                    for i, line in enumerate(lines):
                        if 'dispose()' in line:
                            print(f"{f}:{i+1}:")
                            for k in range(max(0, i-2), min(len(lines), i+10)):
                                print(f"  {k+1}: {lines[k]}")
