import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _roomNameController = TextEditingController();
  final _storageService = StorageService();
  Room? _createdRoom;

  Future<void> _createRoom() async {
    if (_roomNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 이름을 입력해주세요')),
      );
      return;
    }

    final user = await _storageService.getUser();
    if (user == null) return;

    final room = Room.create(_roomNameController.text.trim(), user.id);
    await _storageService.addRoom(room);

    setState(() => _createdRoom = room);
  }

  void _copyLink() {
    if (_createdRoom == null) return;
    Clipboard.setData(ClipboardData(text: _createdRoom!.linkCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('링크가 복사되었습니다')),
    );
  }

  void _copyPassword() {
    if (_createdRoom == null) return;
    Clipboard.setData(ClipboardData(text: _createdRoom!.password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('비밀번호가 복사되었습니다')),
    );
  }

  void _shareRoom() {
    if (_createdRoom == null) return;
    Share.share(
      'SETLOG 방에 초대합니다!\n\n'
      '방 이름: ${_createdRoom!.name}\n'
      '링크 코드: ${_createdRoom!.linkCode}\n'
      '비밀번호: ${_createdRoom!.password}\n\n'
      '매시간 알림이 오면 2초 영상을 찍어 함께 하루를 기록해봐요!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('방 만들기'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _createdRoom == null
              ? _buildCreateForm()
              : _buildCreatedResult(),
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Text(
          '함께 하루를 기록할\n방을 만들어보세요',
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 60),
        TextField(
          controller: _roomNameController,
          decoration: const InputDecoration(
            labelText: '방 이름',
            hintText: '예) 친구들과 함께',
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _createRoom,
          child: const Text('방 만들기'),
        ),
      ],
    );
  }

  Widget _buildCreatedResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '방이 생성되었어요!',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _createdRoom!.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildInfoCard(
          '링크 코드',
          _createdRoom!.linkCode,
          _copyLink,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          '비밀번호',
          _createdRoom!.password,
          _copyPassword,
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _shareRoom,
          icon: const Icon(Icons.share),
          label: const Text('친구에게 공유하기'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('홈으로 돌아가기'),
        ),
        const Spacer(),
        Text(
          '친구들에게 링크 코드와 비밀번호를\n공유하여 방에 초대하세요',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, VoidCallback onCopy) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCopy,
            icon: const Icon(Icons.copy),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }
}
