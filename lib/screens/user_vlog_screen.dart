import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class UserVlogScreen extends StatelessWidget {
  final UserModel user;
  final List<ClipModel> clips;

  const UserVlogScreen({super.key, required this.user, required this.clips});

  @override
  Widget build(BuildContext context) {
    final sorted = List<ClipModel>.from(clips)
      ..sort((a, b) => a.hour.compareTo(b.hour));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 슬리버 헤더
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.beige),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroSection(user, clips),
            ),
          ),

          // 유저 정보
          SliverToBoxAdapter(child: _buildUserInfo(user)),

          // 하루 타임라인
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: const Text('📅 오늘의 하루', style: AppTextStyles.titleMedium),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildClipCard(sorted[index]),
                childCount: sorted.length,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeroSection(UserModel user, List<ClipModel> clips) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent,
            AppColors.primaryLight.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // 클립 모자이크 배경에 프로필
              Stack(
                alignment: Alignment.center,
                children: [
                  // 배경 클립들
                  SizedBox(
                    width: 200,
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: clips.take(5).map((c) {
                        return Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: c.avatarColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(c.emoji, style: const TextStyle(fontSize: 18)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(UserModel user) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.beige),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(
                nickname: user.nickname,
                color: AppColors.primary,
                size: 56,
                isOnline: user.isOnline,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(user.nickname, style: AppTextStyles.titleLarge),
                        const SizedBox(width: 6),
                        Text('${user.age}세', style: AppTextStyles.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 4),
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
              ),
              Column(
                children: [
                  Text(
                    '${clips.length}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text('오늘 클립', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(user.bio, style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          )),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: user.tags.map((tag) => TagChip(label: tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClipCard(ClipModel clip) {
    return Container(
      decoration: BoxDecoration(
        color: clip.avatarColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: clip.avatarColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(clip.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            '${clip.hour}:00',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text('의 순간', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: RoundedButton(
              label: '방에 초대하기',
              onTap: () {},
              isOutlined: true,
              icon: Icons.add_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RoundedButton(
              label: '채팅하기',
              onTap: () => Navigator.pop(context),
              icon: Icons.chat_bubble_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
