import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

// 하루 끝 분할화면 브이로그 자동 완성 화면
class VlogResultScreen extends StatelessWidget {
  final Room room;
  const VlogResultScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final clips = room.todayClips;
    final members = clips.map((c) => c.userName).toSet().toList();
    final today = DateFormat('yyyy년 M월 d일').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(today,
            style: const TextStyle(color: Colors.white, fontSize: 15)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => Share.share(
              '${room.name}의 오늘 하루 브이로그 완성!\n$today\n${clips.length}개 클립 • ${members.length}명 참여'),
          ),
        ],
      ),
      body: Column(children: [
        // 분할화면 메인 뷰
        Expanded(child: _buildSplitScreen(context, members, clips)),

        // 하단 타임라인
        _buildTimeline(context, clips),
      ]),
    );
  }

  // 분할 화면 (최대 4명까지 분할)
  Widget _buildSplitScreen(BuildContext context,
      List<String> members, List<VideoClip> clips) {
    if (members.isEmpty) {
      return const Center(
        child: Text('아직 클립이 없어요',
            style: TextStyle(color: Colors.white54, fontSize: 18)),
      );
    }

    return Column(children: [
      Expanded(
        child: members.length == 1
            ? _oneCell(members[0], clips)
            : members.length == 2
                ? Row(children: [
                    Expanded(child: _oneCell(members[0], clips)),
                    const VerticalDivider(width: 2, color: Colors.black),
                    Expanded(child: _oneCell(members[1], clips)),
                  ])
                : members.length == 3
                    ? Row(children: [
                        Expanded(child: _oneCell(members[0], clips)),
                        const VerticalDivider(width: 2, color: Colors.black),
                        Expanded(
                          child: Column(children: [
                            Expanded(child: _oneCell(members[1], clips)),
                            const Divider(height: 2, color: Colors.black),
                            Expanded(child: _oneCell(members[2], clips)),
                          ]),
                        ),
                      ])
                    : GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                        physics: const NeverScrollableScrollPhysics(),
                        children: members.take(4)
                            .map((m) => _oneCell(m, clips)).toList(),
                      ),
      ),
    ]);
  }

  Widget _oneCell(String memberName, List<VideoClip> clips) {
    final memberClips = clips.where((c) => c.userName == memberName).toList();
    // 색상 팔레트 (멤버별 구분)
    final colors = [
      const Color(0xFF2C2C2C),
      const Color(0xFF1A1A2E),
      const Color(0xFF16213E),
      const Color(0xFF0F3460),
    ];
    final idx = memberClips.isNotEmpty
        ? memberClips.first.userName.length % colors.length
        : 0;

    return Container(
      color: colors[idx],
      child: Stack(children: [
        // 영상 플레이어 (데모 - 실제 앱에서는 video_player 사용)
        Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.play_circle_outline, size: 48,
                color: Colors.white.withValues(alpha: 0.4)),
            const SizedBox(height: 8),
            Text('${memberClips.length}개 클립',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12)),
          ]),
        ),
        // 이름 오버레이
        Positioned(
          bottom: 8, left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(memberName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  // 하단 타임라인
  Widget _buildTimeline(BuildContext context, List<VideoClip> clips) {
    if (clips.isEmpty) return const SizedBox.shrink();

    final sorted = [...clips]..sort((a, b) =>
        a.recordedAt.compareTo(b.recordedAt));

    return Container(
      height: 120,
      color: Colors.black,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 0, 6),
          child: Text('타임라인',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
        ),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: sorted.length,
            itemBuilder: (_, i) {
              final clip = sorted[i];
              return Container(
                width: 70,
                margin: const EdgeInsets.only(right: 8),
                child: Column(children: [
                  Container(
                    height: 52, width: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppTheme.accentPink.withValues(alpha: 0.5),
                          width: 1),
                    ),
                    child: const Icon(Icons.play_arrow,
                        color: Colors.white38, size: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(DateFormat('HH:mm').format(clip.recordedAt),
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 10)),
                  Text(clip.userName,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 9),
                      overflow: TextOverflow.ellipsis),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}
