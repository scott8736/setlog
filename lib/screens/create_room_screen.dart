import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _ctrl = TextEditingController();
  final _storage = StorageService();
  Room? _room;

  Future<void> _create() async {
    if (_ctrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('방 이름을 입력해주세요')));
      return;
    }
    final user = await _storage.getUser();
    if (user == null) return;
    final room = Room.create(_ctrl.text.trim(), user.id);
    await _storage.addRoom(room);
    setState(() => _room = room);
  }

  void _copyAll() {
    if (_room == null) return;
    Clipboard.setData(ClipboardData(
        text: '링크코드: ${_room!.linkCode}\n비밀번호: ${_room!.password}'));
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크코드와 비밀번호가 복사되었습니다')));
  }

  void _share() {
    if (_room == null) return;
    Share.share(
      '[SETLOG LOVABLE] ${_room!.name} 방에 초대합니다!\n\n'
      '📎 링크코드: ${_room!.linkCode}\n'
      '🔑 비밀번호: ${_room!.password}\n\n'
      '앱에서 "초대받기" → 위 코드와 비번 입력!\n'
      '매시간 2초, 오늘 하루를 함께 기록해요 🎬',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBeige,
      appBar: AppBar(
        title: const Text('방 만들기'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _room == null ? _buildForm() : _buildResult(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        const Text('함께 하루를 기록할\n방을 만들어보세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(height: 48),
        TextField(
          controller: _ctrl,
          decoration: const InputDecoration(hintText: '방 이름 (예: 친구들과 함께)'),
          onSubmitted: (_) => _create(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _create, child: const Text('방 만들기')),
      ],
    );
  }

  Widget _buildResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        // 성공 카드
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: AppTheme.accentPink.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 36, color: AppTheme.accentPink),
            ),
            const SizedBox(height: 16),
            const Text('방이 생성되었어요!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_room!.name,
                style: const TextStyle(color: AppTheme.textLight)),
          ]),
        ),
        const SizedBox(height: 20),

        // 링크코드 카드
        _infoCard('📎 링크코드', _room!.linkCode, onCopy: () {
          Clipboard.setData(ClipboardData(text: _room!.linkCode));
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('링크코드 복사됨')));
        }),
        const SizedBox(height: 12),

        // 비밀번호 카드
        _infoCard('🔑 비밀번호', _room!.password, onCopy: () {
          Clipboard.setData(ClipboardData(text: _room!.password));
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('비밀번호 복사됨')));
        }),
        const SizedBox(height: 28),

        // 안내
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.accentPink.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '친구에게 링크코드와 비밀번호를 공유하면\n앱에서 "초대받기"로 바로 입장할 수 있어요',
            style: TextStyle(fontSize: 13, color: AppTheme.textLight),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton.icon(
          onPressed: _share,
          icon: const Icon(Icons.share),
          label: const Text('친구에게 공유하기'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _copyAll,
          child: const Text('링크코드+비번 한번에 복사'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('홈으로'),
        ),
      ],
    );
  }

  Widget _infoCard(String label, String value, {required VoidCallback onCopy}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                    letterSpacing: 3)),
          ]),
        ),
        IconButton(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_outlined, color: AppTheme.accentPink)),
      ]),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
