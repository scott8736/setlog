import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';
import 'room_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storageService = StorageService();
  List<Room> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _rooms = await _storageService.getRooms();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETLOG'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? _buildEmptyState()
              : _buildRoomList(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'join',
            onPressed: () => _navigateToJoinRoom(),
            label: const Text('방 입장'),
            icon: const Icon(Icons.login),
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: () => _navigateToCreateRoom(),
            label: const Text('방 만들기'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            '참여 중인 방이 없어요',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '방을 만들거나 초대받은 링크로 입장하세요',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildRoomList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        final room = _rooms[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.groups),
            ),
            title: Text(
              room.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${room.memberIds.length}명 참여 • ${room.clips.length}개 클립',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateToRoomDetail(room),
          ),
        );
      },
    );
  }

  Future<void> _navigateToCreateRoom() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
    );
    if (result == true) _loadData();
  }

  Future<void> _navigateToJoinRoom() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const JoinRoomScreen()),
    );
    if (result == true) _loadData();
  }

  void _navigateToRoomDetail(Room room) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room)),
    );
  }
}
