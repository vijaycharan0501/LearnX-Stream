import os

file_path = r'c:\Users\vijay\OneDrive\Desktop\WebSites\LearnX Stream\Website LearnX stream\learnx_stream\lib\features\smart_explain\screens\smart_explain_screen.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace _buildBottomBackButton
old_btn = '''  Widget _buildBottomBackButton(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: _handleBack,
        icon: const Icon(Icons.arrow_back_rounded, size: 16),
        label: const Text('Back to answer'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tealPrimary,
          side: const BorderSide(color: AppColors.tealPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }'''

new_btn = '''  Widget _buildBottomBackButton(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onPressed: _handleBack,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tealPrimary,
          side: const BorderSide(color: AppColors.tealPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_rounded, size: 16),
            SizedBox(width: 8),
            Text('Back to answer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }'''

content = content.replace(old_btn, new_btn)

# Replace Key Idea Header Row
old_key_idea = '''          const Row(
            children: [
              Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.tealPrimary),
              SizedBox(width: 6),
              Text(
                'Key Idea',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.tealPrimary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),'''

new_key_idea = '''          const Row(
            children: [
              Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.tealPrimary),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Key Idea',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.tealPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),'''

content = content.replace(old_key_idea, new_key_idea)

# Replace Understand concept header
old_und = '''    return Row(
      children: [
        const Icon(Icons.menu_book_rounded, size: 16, color: AppColors.tealPrimary),
        const SizedBox(width: 6),
        Text(
          'Understand the Concept',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.getTextPrimary(isDark),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );'''

new_und = '''    return Row(
      children: [
        const Icon(Icons.menu_book_rounded, size: 16, color: AppColors.tealPrimary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Understand the Concept',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.getTextPrimary(isDark),
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );'''

content = content.replace(old_und, new_und)

# Replace Real world card header
old_rw = '''          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.getPurpleLight(isDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.public_rounded, size: 15, color: AppColors.purplePrimary),
              ),
              const SizedBox(width: 8),
              const Text(
                'Where you see this',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.purplePrimary,
                ),
              ),
            ],
          ),'''

new_rw = '''          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.getPurpleLight(isDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.public_rounded, size: 15, color: AppColors.purplePrimary),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Where you see this',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.purplePrimary,
                  ),
                ),
              ),
            ],
          ),'''

content = content.replace(old_rw, new_rw)

# Replace Quick Check card header
old_qc = '''          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.getOrangeLight(isDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.quiz_rounded, size: 16, color: AppColors.orangePrimary),
              ),
              const SizedBox(width: 8),
              const Text(
                'Quick Check',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orangePrimary,
                ),
              ),
            ],
          ),'''

new_qc = '''          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.getOrangeLight(isDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.quiz_rounded, size: 16, color: AppColors.orangePrimary),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Quick Check',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orangePrimary,
                  ),
                ),
              ),
            ],
          ),'''

content = content.replace(old_qc, new_qc)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("smart_explain_screen.dart patched successfully")
