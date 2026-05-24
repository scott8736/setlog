import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'camera_record_screen.dart';
import 'vlog_result_screen.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;
  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final _storage = StorageService();
  late Room _room;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _reload();
  }

  Future<void> _reload() async {
    final r = await _storage.getRoom(_room.id);
    if (r != null && mounted) setState(() => _room = r);
  }

  Future<void> _goCamera() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(
            builder: (_) => CameraRecordScreen(roomId: _room.id)));
    if (result != null) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final clips = _room.todayClips;
    return Scaffold(
      backgroundColor: AppTheme.primaryBeige,
      appBar: AppBar(
        title: Text(_room.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareRoom,
            tooltip: '초대 공유',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: clips.isEmpty ? _buildEmpty() : _buildTimeline(clips),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goCamera,
        icon: const Icon(Icons.videocam),
        label: const Text('지금 찍기'),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.video_call_outlined, size: 80,
            color: AppTheme.accentPink.withValues(alpha: 0.3)),
        const SizedBox(height: 24),
        const Text('오늘 첫 번째 순간을 기록해보세요',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('매시간 알림이 오면 2~4초 촬영!',
            style: TextStyle(color: AppTheme.textLight)),
        const SizedBox(height: 32),
        // 하루 끝 브이로그 완성 버튼 (데모)
        OutlinedButton.icon(
          onPressed: () => _goVlogResult(),
          icon: const Icon(Icons.movie_filter_outlined),
          label: const Text('오늘 브이로그 완성 미리보기'),
        ),
      ]),
    );
  }

  Widget _buildTimeline(List<VideoClip> clips) {
    // 시간 역순 정렬
    final sorted = [...clips]
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    // 시간별 그룹
    final Map<int, List<VideoClip>> grouped = {};
    for (final c in sorted) {
      grouped.putIfAbsent(c.recordedAt.hour, () => []).add(c);
    }
    final hours = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        // 오늘 브이로그 완성 버튼
        _buildVlogBanner(),
        const SizedBox(height: 16),
        ...hours.map((h) => _buildHourSection(h, grouped[h]!)),
      ],
    );
  }

  Widget _buildVlogBanner() {
    final clips = _room.todayClips;
    return GestureDetector(
      onTap: _goVlogResult,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.accentPink.withValues(alpha: 0.8),
              AppTheme.accentPink.withValues(alpha: 0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Icon(Icons.movie_filter, color: Colors.white, size: 32),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('오늘의 브이로그',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${clips.length}개 클립 • 탭해서 완성 미리보기',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          )),
          const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
        ]),
      ),
    );
  }

  Widget _buildHourSection(int hour, List<VideoClip> clips) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.textDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${hour.toString().padLeft(2, '0')}:00',
                style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Text('${clips.length}개',
              style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
        ]),
      ),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10,
          mainAxisSpacing: 10, childAspectRatio: 0.78,
        ),
        itemCount: clips.length,
        itemBuilder: (_, i) => _buildClipCard(clips[i]),
      ),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildClipCard(VideoClip clip) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 영상 썸네일 영역
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.accentPink.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14)),
            ),
            child: Stack(children: [
              Center(child: Icon(Icons.play_circle_outline,
                  size: 44, color: AppTheme.accentPink.withValues(alpha: 0.6))),
              // 무음 배지
              Positioned(
                top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.volume_off, size: 10, color: Colors.white),
                    SizedBox(width: 3),
                    Text('무음', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(clip.userName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 2),
            Text(DateFormat('HH:mm').format(clip.recordedAt),
                style: const TextStyle(
                    color: AppTheme.textLight, fontSize: 12)),
            if (clip.memo != null) ...[
              const SizedBox(height: 4),
              Text(clip.memo!,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textDark,
                      fontStyle: FontStyle.italic),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ]),
        ),
      ]),
    );
  }

  void _goVlogResult() {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (_) => VlogResultScreen(room: _room)));
  }

  void _shareRoom() {
    Share.share(
      '[SETLOG LOVABLE] ${_room.name} 방에 초대합니다!\n\n'
      '📎 링크코드: ${_room.linkCode}\n'
      '🔑 비밀번호: ${_room.password}\n\n'
      '앱에서 "초대받기" 탭 → 코드+비번 입력!\n'
      '매시간 2초, 오늘 하루를 함께 기록해요 🎬',
    );
  }

  void _showInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text(_room.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _infoRow('📎 링크코드', _room.linkCode, copy: true),
          const SizedBox(height: 12),
          _infoRow('🔑 비밀번호', _room.password, copy: true),
          const SizedBox(height: 12),
          _infoRow('👥 참여 인원', '${_room.memberIds.length}명'),
          const SizedBox(height: 12),
          _infoRow('🎬 오늘 클립', '${_room.todayClips.length}개'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBeige,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '📅 영상은 당일 자정에 자동 삭제됩니다',
              style: TextStyle(fontSize: 12, color: AppTheme.textLight),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool copy = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textLight)),
        Row(children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (copy) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$value 복사됨')));
              },
              child: const Icon(Icons.copy_outlined,
                  size: 16, color: AppTheme.accentPink),
            ),
          ],
        ]),
      ],
    );
  }
}
