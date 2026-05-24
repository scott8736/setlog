import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/mock_data.dart';
import '../widgets/common_widgets.dart';
import 'user_vlog_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<MatchModel> _matches = MockDataService.matches;
  final Set<String> _likedIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textHint,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: AppColors.divider,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              tabs: [
                Tab(text: '추천 (${_matches.length})'),
                Tab(text: '좋아요한 사람 (${_likedIds.length})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMatchList(_matches),
                  _buildLikedList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('하루로 만나기 💕', style: AppTextStyles.titleLarge),
              const SizedBox(height: 2),
              Text(
                '오늘 하루를 공유한 사람들을 만나보세요',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchList(List<MatchModel> matches) {
    if (matches.isEmpty) {
      return const EmptyStateWidget(
        emoji: '🔍',
        title: '아직 추천 상대가 없어요',
        subtitle: '방에서 하루를 기록하면\n비슷한 취향의 사람을 연결해드려요!',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildMatchCard(matches[index]),
    );
  }

  Widget _buildLikedList() {
    final liked = _matches.where((m) => _likedIds.contains(m.id)).toList();
    if (liked.isEmpty) {
      return const EmptyStateWidget(
        emoji: '🫶',
        title: '아직 좋아요한 사람이 없어요',
        subtitle: '마음에 드는 사람에게\n하트를 눌러보세요!',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: liked.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildMatchCard(liked[index]),
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    final isLiked = _likedIds.contains(match.id);
    final userColor = MockDataService.getAvatarColor(
      MockDataService.users.indexWhere((u) => u.id == match.user.id),
    );

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserVlogScreen(
            user: match.user,
            clips: match.previewClips,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.beige),
        ),
        child: Column(
          children: [
            // 상단: 프로필 + 호환성
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ProfileAvatar(
                    nickname: match.user.nickname,
                    color: userColor,
                    size: 52,
                    isOnline: match.user.isOnline,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(match.user.nickname, style: AppTextStyles.titleMedium),
                            const SizedBox(width: 6),
                            Text(
                              '${match.user.age}세',
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                match.user.mbti,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          match.user.bio,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          children: match.sharedTags
                              .map((tag) => TagChip(label: tag, isSelected: true))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  CompatibilityBadge(score: match.compatibilityScore),
                ],
              ),
            ),

            // 클립 프리뷰
            if (match.previewClips.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: match.previewClips.length.clamp(0, 6),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, index) {
                      final clip = match.previewClips[index];
                      return Column(
                        children: [
                          ClipAvatar(
                            color: clip.avatarColor,
                            emoji: clip.emoji,
                            size: 36,
                          ),
                          const SizedBox(height: 2),
                          Text('${clip.hour}시', style: AppTextStyles.caption),
                        ],
                      );
                    },
                  ),
                ),
              ),

            // 하단 액션
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Text(
                    '${match.previewClips.length}개의 순간',
                    style: AppTextStyles.caption,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          if (isLiked) {
                            _likedIds.remove(match.id);
                          } else {
                            _likedIds.add(match.id);
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isLiked ? AppColors.accent : AppColors.cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isLiked ? AppColors.primary : AppColors.beige,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 15,
                                color: isLiked ? AppColors.primary : AppColors.textHint,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isLiked ? '좋아요!' : '좋아요',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isLiked ? AppColors.primary : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '하루 보기',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
