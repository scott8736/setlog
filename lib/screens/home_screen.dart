import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/mock_data.dart';
import '../widgets/common_widgets.dart';
import 'room_detail_screen.dart';
import 'create_room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<RoomModel> _rooms = MockDataService.rooms;
  final int _minutesLeft = MockDataService.minutesUntilNextNotification;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── 앱바
            SliverToBoxAdapter(child: _buildHeader()),

            // ── 오늘 나의 순간 카드
            SliverToBoxAdapter(child: _buildMyMomentCard()),

            // ── 다음 알림까지
            SliverToBoxAdapter(child: _buildNextAlarmBanner()),

            // ── 참여 중인 방 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 4),
                child: SectionHeader(
                  title: '참여 중인 방',
                  actionLabel: '+ 새 방 만들기',
                  onAction: () => _showCreateRoom(context),
                ),
              ),
            ),

            // ── 방 카드 리스트
            if (_rooms.isEmpty)
              SliverToBoxAdapter(
                child: EmptyStateWidget(
                  emoji: '🏠',
                  title: '아직 참여 중인 방이 없어요',
                  subtitle: '방을 만들어 초대 링크를 공유해보세요!',
                  buttonLabel: '방 만들기',
                  onButton: () => _showCreateRoom(context),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildRoomCard(_rooms[index]),
                  childCount: _rooms.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  // ── 헤더
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'SETLOG',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'LOVABLE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDeep,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '오늘도 하루를 기록해요 ✨',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          Row(
            children: [
              _buildIconButton(Icons.notifications_outlined, () {}),
              const SizedBox(width: 4),
              _buildIconButton(Icons.person_outline_rounded, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.beige),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
    );
  }

  // ── 나의 오늘 순간 카드
  Widget _buildMyMomentCard() {
    final clipCount = MockDataService.todayClipCount;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.accent,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘 나의 기록',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$clipCount',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDeep,
                          letterSpacing: -1,
                        ),
                      ),
                      const TextSpan(
                        text: '  번 찍었어요 📸',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildProgressBar(clipCount, 8),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _showCaptureSheet(context),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.videocam_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int current, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current / total,
            backgroundColor: AppColors.beige,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '목표 $total번 중 $current번',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  // ── 다음 알림 배너
  Widget _buildNextAlarmBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.beige),
      ),
      child: Row(
        children: [
          const Text('⏰', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '다음 촬영 알림까지 $_minutesLeft분 남았어요',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showCaptureSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '지금 찍기',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDeep,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 방 카드
  Widget _buildRoomCard(RoomModel room) {
    final participants = room.participantIds.length;
    final clips = room.todayClips;
    final myClipCount = clips.where((c) => c.userId == 'me').length;

    // 참여자별 고유 클립 수
    final clipsByUser = <String, List<ClipModel>>{};
    for (final c in clips) {
      clipsByUser.putIfAbsent(c.userId, () => []).add(c);
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room)),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.beige),
        ),
        child: Column(
          children: [
            // 상단 정보
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 방 아이콘
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        room.roomType == 'group' ? '👥' : '💑',
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.title,
                          style: AppTextStyles.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$participants명 참여 · 오늘 ${clips.length}개 클립',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                ],
              ),
            ),

            // 클립 미리보기 그리드
            if (clips.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildClipGrid(clips, clipsByUser),
              ),

            // 하단 바
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  const Text('📍', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '내 기록 $myClipCount개',
                    style: AppTextStyles.caption,
                  ),
                  const Spacer(),
                  Text(
                    '초대코드: ${room.inviteCode}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClipGrid(List<ClipModel> clips, Map<String, List<ClipModel>> clipsByUser) {
    final userIds = clipsByUser.keys.toList();
    final displayCount = userIds.length.clamp(1, 4);

    if (displayCount == 1) {
      // 1명: 가로 스크롤 타임라인
      return SizedBox(
        height: 64,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: clips.length.clamp(0, 8),
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final clip = clips[index];
            return Column(
              children: [
                ClipAvatar(
                  color: clip.avatarColor,
                  emoji: clip.emoji,
                  size: 40,
                ),
                const SizedBox(height: 4),
                Text(
                  '${clip.hour}시',
                  style: AppTextStyles.caption,
                ),
              ],
            );
          },
        ),
      );
    }

    // 2~4명: 분할 그리드
    return SizedBox(
      height: 80,
      child: Row(
        children: List.generate(displayCount, (i) {
          final uid = userIds[i];
          final userClips = clipsByUser[uid]!;
          final latestClip = userClips.last;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < displayCount - 1 ? 6 : 0),
              decoration: BoxDecoration(
                color: latestClip.avatarColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: latestClip.avatarColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(latestClip.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    latestClip.userNickname,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${userClips.length}개',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showCreateRoom(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
    );
  }

  void _showCaptureSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CaptureBottomSheet(),
    );
  }
}

// ── 촬영 바텀시트
class _CaptureBottomSheet extends StatefulWidget {
  @override
  State<_CaptureBottomSheet> createState() => _CaptureBottomSheetState();
}

class _CaptureBottomSheetState extends State<_CaptureBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _isDone = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: AppColors.beige,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          if (_isDone) ...[
            const Text('✅', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            const Text('기록 완료!', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            const Text(
              '오늘의 순간이 방에 공유됐어요 🎉',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            RoundedButton(
              label: '닫기',
              onTap: () => Navigator.pop(context),
              width: double.infinity,
            ),
          ] else ...[
            const Text('지금 이 순간을\n2초만 찍어보세요 📸',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${DateTime.now().hour}시의 나를 기록해요',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 32),

            // 촬영 버튼
            GestureDetector(
              onTap: _isRecording ? null : _startRecording,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) {
                  final scale = _isRecording
                      ? 1.0 + _pulseController.value * 0.08
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: _isRecording ? AppColors.error : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? AppColors.error : AppColors.primary)
                                .withValues(alpha: 0.35),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop_rounded : Icons.videocam_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isRecording ? '녹화 중...' : '버튼을 눌러 2초 녹화',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  void _startRecording() async {
    setState(() => _isRecording = true);
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) setState(() { _isRecording = false; _isDone = true; });
  }
}
