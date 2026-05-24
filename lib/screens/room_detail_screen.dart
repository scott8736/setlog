import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import 'camera_record_screen.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late Room _room;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
  }

  void _navigateToCamera() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CameraRecordScreen(roomId: _room.id),
      ),
    );

    if (result != null && result is VideoClip) {
      setState(() {
        _room = Room(
          id: _room.id,
          name: _room.name,
          linkCode: _room.linkCode,
          password: _room.password,
          createdAt: _room.createdAt,
          memberIds: _room.memberIds,
          clips: [..._room.clips, result],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_room.name),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showRoomInfo,
          ),
        ],
      ),
      body: _room.clips.isEmpty ? _buildEmptyState() : _buildClipGrid(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCamera,
        icon: const Icon(Icons.videocam),
        label: const Text('2초 촬영'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_call_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            '아직 촬영된 클립이 없어요',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 2초 영상을 촬영해보세요!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildClipGrid() {
    // 시간별로 그룹화
    final clipsByHour = <String, List<VideoClip>>{};
    for (final clip in _room.clips) {
      final hourKey = DateFormat('HH:00').format(clip.recordedAt);
      clipsByHour.putIfAbsent(hourKey, () => []).add(clip);
    }

    final sortedHours = clipsByHour.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedHours.length,
      itemBuilder: (context, index) {
        final hour = sortedHours[index];
        final clips = clipsByHour[hour]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                hour,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: clips.length,
              itemBuilder: (context, clipIndex) {
                final clip = clips[clipIndex];
                return _buildClipCard(clip);
              },
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildClipCard(VideoClip clip) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clip.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(clip.recordedAt),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRoomInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_room.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('링크 코드', _room.linkCode),
            const SizedBox(height: 8),
            _buildInfoRow('비밀번호', _room.password),
            const SizedBox(height: 8),
            _buildInfoRow('참여 인원', '${_room.memberIds.length}명'),
            const SizedBox(height: 8),
            _buildInfoRow('클립 수', '${_room.clips.length}개'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
