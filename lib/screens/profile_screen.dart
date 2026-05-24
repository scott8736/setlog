import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/mock_data.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockDataService.currentUser;
    final myClips = MockDataService.rooms
        .expand((r) => r.todayClips.where((c) => c.userId == 'me'))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(user)),
            SliverToBoxAdapter(child: _buildStatsRow(user, myClips.length)),
            SliverToBoxAdapter(child: _buildTagsSection(user)),
            SliverToBoxAdapter(child: _buildMyClipsSection(myClips)),
            SliverToBoxAdapter(child: _buildSettingsSection(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.beige),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 15, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      '프로필 편집',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 프로필 아바타 + 정보
          ProfileAvatar(
            nickname: user.nickname,
            color: AppColors.primary,
            size: 80,
            isOnline: true,
          ),
          const SizedBox(height: 12),
          Text(user.nickname, style: AppTextStyles.displayMedium),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${user.age}세', style: AppTextStyles.bodyMedium),
              Container(
                width: 3, height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: const BoxDecoration(
                  color: AppColors.textHint,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user.mbti,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(user.bio, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserModel user, int clipCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.beige),
      ),
      child: Row(
        children: [
          _stat('$clipCount개', '오늘 기록'),
          _statDivider(),
          _stat('${MockDataService.rooms.length}개', '참여 방'),
          _statDivider(),
          _stat('${MockDataService.matches.length}명', '추천 매칭'),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary,
          )),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _statDivider() =>
      Container(width: 1, height: 28, color: AppColors.divider);

  Widget _buildTagsSection(UserModel user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: '나의 취향 태그'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.tags.map((tag) => TagChip(label: tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMyClipsSection(List<ClipModel> clips) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📸 오늘 나의 기록', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          if (clips.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.beige),
              ),
              child: const Column(
                children: [
                  Text('📷', style: TextStyle(fontSize: 36)),
                  SizedBox(height: 8),
                  Text('아직 오늘 기록이 없어요', style: AppTextStyles.bodyMedium),
                ],
              ),
            )
          else
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: clips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final clip = clips[index];
                  return Column(
                    children: [
                      ClipAvatar(
                        color: clip.avatarColor,
                        emoji: clip.emoji,
                        size: 48,
                      ),
                      const SizedBox(height: 4),
                      Text('${clip.hour}시', style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600,
                      )),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('설정', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.beige),
            ),
            child: Column(
              children: [
                _settingItem(Icons.notifications_outlined, '알림 설정', onTap: () {}),
                const Divider(height: 1, indent: 52),
                _settingItem(Icons.lock_outline_rounded, '개인정보 보호', onTap: () {}),
                const Divider(height: 1, indent: 52),
                _settingItem(Icons.block_outlined, '차단 목록', onTap: () {}),
                const Divider(height: 1, indent: 52),
                _settingItem(Icons.help_outline_rounded, '고객센터', onTap: () {}),
                const Divider(height: 1, indent: 52),
                _settingItem(
                  Icons.logout_rounded,
                  '로그아웃',
                  color: AppColors.error,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingItem(
    IconData icon,
    String label, {
    VoidCallback? onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color ?? AppColors.textPrimary,
                ),
              ),
            ),
            if (color == null)
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
