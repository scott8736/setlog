import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _titleController = TextEditingController();
  String _roomType = 'solo'; // solo | group
  bool _isCreated = false;
  final String _generatedCode = 'SL-${DateTime.now().millisecond.toString().padLeft(4, '0')}';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.beige),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
          ),
        ),
        title: const Text('새 방 만들기'),
      ),
      body: _isCreated ? _buildSuccessView() : _buildCreateForm(),
    );
  }

  Widget _buildCreateForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 방 제목
          const Text('방 이름', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: '예) 지현이와 오늘 하루 🌿',
            ),
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: 24),

          // 방 유형
          const Text('방 유형', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTypeCard('solo', '💑', '1:1 소개팅', '단 둘이 하루를 공유해요')),
              const SizedBox(width: 10),
              Expanded(child: _buildTypeCard('group', '👥', '그룹 방', '여러 명이 함께 기록해요')),
            ],
          ),
          const SizedBox(height: 24),

          // 방 규칙 안내
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('📋', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 6),
                    Text('방 규칙', style: AppTextStyles.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRule('⏰', '매시간 알림이 울리면 2초 영상 촬영'),
                _buildRule('📺', '자정에 하루 브이로그 자동 완성'),
                _buildRule('💬', '영상 공유 후 채팅 오픈'),
                _buildRule('🔒', '24시간 후 방 자동 비공개'),
              ],
            ),
          ),
          const SizedBox(height: 32),

          RoundedButton(
            label: '방 만들기',
            onTap: _createRoom,
            icon: Icons.add_rounded,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(String type, String emoji, String title, String subtitle) {
    final isSelected = _roomType == type;
    return GestureDetector(
      onTap: () => setState(() => _roomType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.beige,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 15)),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.bodySmall),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '선택됨',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRule(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary, fontSize: 13,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🎉', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('방이 만들어졌어요!', style: AppTextStyles.displayMedium),
          const SizedBox(height: 8),
          Text(
            _titleController.text.isNotEmpty
                ? '"${_titleController.text}"'
                : '새로운 방',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 32),

          // 초대 코드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.beige),
            ),
            child: Column(
              children: [
                const Text('초대 코드', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  _generatedCode,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RoundedButton(
                        label: '코드 복사',
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _generatedCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('초대 코드가 복사됐어요!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        isOutlined: true,
                        icon: Icons.copy_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RoundedButton(
                        label: '공유하기',
                        onTap: () {},
                        icon: Icons.share_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('홈으로 돌아가기'),
          ),
        ],
      ),
    );
  }

  void _createRoom() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('방 이름을 입력해주세요'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isCreated = true);
  }
}
