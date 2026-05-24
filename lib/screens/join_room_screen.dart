import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _linkCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storageService = StorageService();

  Future<void> _joinRoom() async {
    final linkCode = _linkCodeController.text.trim();
    final password = _passwordController.text.trim();

    if (linkCode.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크 코드와 비밀번호를 모두 입력해주세요')),
      );
      return;
    }

    // 실제 앱에서는 서버에서 방 정보 확인
    // 지금은 데모용으로 로컬에서만 확인
    final rooms = await _storageService.getRooms();
    final existingRoom = rooms.where((r) => 
      r.linkCode == linkCode && r.password == password
    ).firstOrNull;

    if (existingRoom != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 참여 중인 방입니다')),
        );
      }
      return;
    }

    // 데모: 방을 찾을 수 없음 안내
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('방을 찾을 수 없습니다. 링크 코드와 비밀번호를 확인해주세요'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('방 입장'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                '초대받은 방에\n입장하세요',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              TextField(
                controller: _linkCodeController,
                decoration: const InputDecoration(
                  labelText: '링크 코드',
                  hintText: '8자리 코드 입력',
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 8,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  hintText: '4자리 숫자',
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _joinRoom,
                child: const Text('입장하기'),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '친구에게 받은 링크 코드와 비밀번호를\n정확히 입력해주세요',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _linkCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
