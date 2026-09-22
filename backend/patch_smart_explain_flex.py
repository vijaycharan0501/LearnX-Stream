import os

file_path = r'c:\Users\vijay\OneDrive\Desktop\WebSites\LearnX Stream\Website LearnX stream\learnx_stream\lib\features\smart_explain\screens\smart_explain_screen.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Patch AI chose row
old_ai_chose = '''                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.psychology_rounded, size: 13, color: AppColors.tealPrimary),
                    const SizedBox(width: 4),
                    Text(
                      activeName == aiChosenName ? 'AI chose: $aiChosenName' : 'Showing: $activeName',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tealPrimary,
                      ),
                    ),
                  ],
                ),'''

new_ai_chose = '''                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.psychology_rounded, size: 13, color: AppColors.tealPrimary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        activeName == aiChosenName ? 'AI chose: $aiChosenName' : 'Showing: $activeName',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tealPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),'''

content = content.replace(old_ai_chose, new_ai_chose)

# 2. Patch "Let's understand it visually."
old_understand = '''              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.visibility_rounded, size: 15, color: AppColors.tealPrimary),
                  const SizedBox(width: 6),
                  Text(
                    "Let's understand it visually.",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                ],
              ),'''

new_understand = '''              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.visibility_rounded, size: 15, color: AppColors.tealPrimary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "Let's understand it visually.",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),'''

content = content.replace(old_understand, new_understand)

# 3. Patch Visualization Card Header Row
old_vis_header = '''                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.tealPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '✨ Visualization Concept',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.tealPrimary,
                      ),
                    ),
                  ],
                ),'''

new_vis_header = '''                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.tealPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        '✨ Visualization Concept',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.tealPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),'''

content = content.replace(old_vis_header, new_vis_header)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("smart_explain_screen.dart patched with Flexible text in Rows successfully")
