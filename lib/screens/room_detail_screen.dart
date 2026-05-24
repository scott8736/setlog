import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class RoomDetailScreen extends StatefulWidget {
  final RoomModel room;
  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final room = widget.room;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
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
        title: Text(room.title, style: AppTextStyles.titleMedium),
        actions: [
          GestureDetector(
            onTap: () => _shareInviteCode(context, room.inviteCode),
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 8, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.share_outlined, size: 15, color: AppColors.primaryDeep),
                  SizedBox(width: 4),
                  Text(
                    '초대',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppColors.divider,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '오늘 하루'),
            Tab(text: '타임라인'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayView(room),
          _buildTimelineView(room),
        ],
      ),
    );
  }

  // ── 오늘 하루 탭: 분할 화면 브이로그
  Widget _buildTodayView(RoomModel room) {
    final clipsByUser = <String, List<ClipModel>>{};
    for (final c in room.todayClips) {
      clipsByUser.putIfAbsent(c.userId, () => []).add(c);
    }
    final userIds = clipsByUser.keys.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 통계
          _buildStats(room),
          const SizedBox(height: 20),

          // 분할 화면 뷰
          if (userIds.length >= 2)
            _buildSplitView(userIds, clipsByUser)
          else
            _buildSingleUserView(userIds, clipsByUser),

          const SizedBox(height: 20),

          // 가장 최근 순간들
          const Text('💫 오늘의 순간들', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          _buildMomentGrid(room.todayClips),
        ],
      ),
    );
  }

  Widget _buildStats(RoomModel room) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.beige),
      ),
      child: Row(
        children: [
          _buildStatItem('참여자', '${room.participantCount}명'),
          _buildStatDivider(),
          _buildStatItem('총 클립', '${room.todayClips.length}개'),
          _buildStatDivider(),
          _buildStatItem('달성률', '${(room.completionRate * 100).toInt()}%'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.displayMedium.copyWith(
            fontSize: 20, color: AppColors.primary,
          )),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 32, color: AppColors.divider);
  }

  // ── 분할 화면 브이로그
  Widget _buildSplitView(
      List<String> userIds, Map<String, List<ClipModel>> clipsByUser) {
    final displayCount = userIds.length.clamp(1, 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📺 함께한 하루', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: displayCount >= 3 ? 1.2 : 1.6,
          child: displayCount <= 2
              ? Row(
                  children: List.generate(
                    displayCount,
                    (i) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == 0 ? 4 : 0),
                        child: _buildUserPanel(
                          userIds[i],
                          clipsByUser[userIds[i]]!,
                        ),
                      ),
                    ),
                  ),
                )
              : GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(
                    displayCount,
                    (i) => _buildUserPanel(
                      userIds[i],
                      clipsByUser[userIds[i]]!,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildUserPanel(String userId, List<ClipModel> clips) {
    final latest = clips.last;
    return Container(
      decoration: BoxDecoration(
        color: latest.avatarColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: latest.avatarColor.withValues(alpha: 0.3)),
      ),
      child: Stack(
        children: [
          // 이모지 그리드 배경
          Positioned.fill(
            child: GridView.count(
              crossAxisCount: 3,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: clips.take(9).map((c) {
                return Container(
                  decoration: BoxDecoration(
                    color: c.avatarColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(c.emoji, style: const TextStyle(fontSize: 16)),
                  ),
                );
              }).toList(),
            ),
          ),
          // 하단 사용자 정보
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    latest.avatarColor.withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    userId == 'me' ? '나' : latest.userNickname,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${clips.length}컷',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 현재 사용자 표시
          if (userId == 'me')
            Positioned(
              top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ME',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleUserView(
      List<String> userIds, Map<String, List<ClipModel>> clipsByUser) {
    if (userIds.isEmpty) return const SizedBox.shrink();
    final uid = userIds[0];
    final clips = clipsByUser[uid]!;
    return _buildUserPanel(uid, clips);
  }

  // ── 순간 그리드
  Widget _buildMomentGrid(List<ClipModel> clips) {
    final sorted = List<ClipModel>.from(clips)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final clip = sorted[index];
        return Column(
          children: [
            ClipAvatar(color: clip.avatarColor, emoji: clip.emoji, size: 44),
            const SizedBox(height: 4),
            Text(clip.userNickname == '나' ? '나' : clip.userNickname,
                style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${clip.hour}시', style: AppTextStyles.caption.copyWith(
              color: AppColors.primary, fontWeight: FontWeight.w600,
            )),
          ],
        );
      },
    );
  }

  // ── 타임라인 탭
  Widget _buildTimelineView(RoomModel room) {
    final sorted = List<ClipModel>.from(room.todayClips)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        final clip = sorted[index];
        final isFirst = index == 0;
        final isLast = index == sorted.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 타임라인 선
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    if (!isFirst)
                      Container(width: 1.5, height: 12, color: AppColors.beige),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: clip.userId == 'me' ? AppColors.primary : AppColors.beigeDeep,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Expanded(child: Container(width: 1.5, color: AppColors.beige)),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.beige),
                  ),
                  child: Row(
                    children: [
                      ClipAvatar(color: clip.avatarColor, emoji: clip.emoji, size: 40),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clip.userId == 'me' ? '나' : clip.userNickname,
                              style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
                            ),
                            Text(
                              '${clip.hour}시의 순간',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${clip.hour}:00',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareInviteCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.beige, borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('🔗', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 16),
            const Text('초대 코드', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: AppColors.primaryDeep,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('클립보드에 복사됐어요!', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 24),
            RoundedButton(
              label: '닫기',
              onTap: () => Navigator.pop(context),
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
