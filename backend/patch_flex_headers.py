import os

# 1. Patch app_top_header.dart
header_path = r'c:\Users\vijay\OneDrive\Desktop\WebSites\LearnX Stream\Website LearnX stream\learnx_stream\lib\core\widgets\app_top_header.dart'
with open(header_path, 'r', encoding='utf-8') as f:
    h_content = f.read()

old_theme_text = '''                Text(
                  isDark ? 'Dark' : 'Light',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),'''

new_theme_text = '''                Flexible(
                  child: Text(
                    isDark ? 'Dark' : 'Light',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),'''

h_content = h_content.replace(old_theme_text, new_theme_text)
with open(header_path, 'w', encoding='utf-8') as f:
    f.write(h_content)

# 2. Patch smart_explain_screen.dart
screen_path = r'c:\Users\vijay\OneDrive\Desktop\WebSites\LearnX Stream\Website LearnX stream\learnx_stream\lib\features\smart_explain\screens\smart_explain_screen.dart'
with open(screen_path, 'r', encoding='utf-8') as f:
    s_content = f.read()

# LearnX AI text
old_learnx_ai = '''                  Text(
                    'LEARNX AI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.getTextMuted(isDark),
                      letterSpacing: 0.5,
                    ),
                  ),'''

new_learnx_ai = '''                  Flexible(
                    child: Text(
                      'LEARNX AI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.getTextMuted(isDark),
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),'''

s_content = s_content.replace(old_learnx_ai, new_learnx_ai)

# Try another way button text
old_try_btn = '''                      Text(
                        'Try another way',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),'''

new_try_btn = '''                      Flexible(
                        child: Text(
                          'Try another way',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),'''

s_content = s_content.replace(old_try_btn, new_try_btn)

# Back to answer bottom button
old_back_btn = '''            Text('Back to answer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),'''

new_back_btn = '''            Flexible(child: Text('Back to answer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis)),'''

s_content = s_content.replace(old_back_btn, new_back_btn)

with open(screen_path, 'w', encoding='utf-8') as f:
    f.write(s_content)

print("Patched app_top_header and smart_explain_screen successfully")
