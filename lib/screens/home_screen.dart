import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';
import 'room_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  List<Room> _rooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _rooms = await _storage.getRooms();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBeige,
      appBar: AppBar(
        title: const Text('SETLOG',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty ? _buildEmpty() : _buildList(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'join',
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const JoinRoomScreen()));
              _load();
            },
            label: const Text('초대받기'),
            icon: const Icon(Icons.link),
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.accentPink,
            elevation: 2,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CreateRoomScreen()));
              _load();
            },
            label: const Text('방 만들기'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_outlined, size: 80,
              color: AppTheme.accentPink.withValues(alpha: 0.4)),
          const SizedBox(height: 24),
          const Text('참여 중인 방이 없어요',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('방을 만들거나 친구 초대 링크로 입장하세요',
              style: TextStyle(color: AppTheme.textLight)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: _rooms.length,
      itemBuilder: (_, i) => _buildRoomCard(_rooms[i]),
    );
  }

  Widget _buildRoomCard(Room room) {
    final todayClips = room.todayClips;
    final now = DateTime.now();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    final remaining = nextHour.difference(now);
    final mm = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return GestureDetector(
      onTap: () async {
        await Navigator.push(context,
            MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room)));
        _load();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.accentPink.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.groups_2_outlined,
                      color: AppTheme.accentPink, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${room.memberIds.length}명 참여 • 오늘 ${todayClips.length}개 클립',
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textLight)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppTheme.textLight),
              ],
            ),
            const SizedBox(height: 14),
            // 다음 촬영까지 타이머
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBeige,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 16, color: AppTheme.accentPink),
                  const SizedBox(width: 6),
                  Text('다음 촬영까지  $mm:$ss',
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textDark,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (todayClips.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('오늘 ${DateFormat('HH:mm').format(todayClips.last.recordedAt)} 마지막 촬영',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
            ],
          ],
        ),
      ),
    );
  }
}
