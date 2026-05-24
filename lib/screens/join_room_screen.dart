import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'room_detail_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  // 딥링크로 진입 시 linkCode가 자동으로 채워짐
  final String? initialLinkCode;
  const JoinRoomScreen({super.key, this.initialLinkCode});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _linkCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _storage = StorageService();
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    // 딥링크로 넘어온 경우 링크코드 자동 채우기
    if (widget.initialLinkCode != null) {
      _linkCtrl.text = widget.initialLinkCode!;
    }
  }

  Future<void> _join() async {
    final link = _linkCtrl.text.trim().toUpperCase();
    final pw = _pwCtrl.text.trim();

    if (link.isEmpty || pw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('링크코드와 비밀번호를 입력해주세요')));
      return;
    }

    setState(() => _joining = true);

    final room = await _storage.findRoomByLinkAndPassword(link, pw);

    if (room == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('방을 찾을 수 없어요. 코드와 비밀번호를 확인해주세요')));
        setState(() => _joining = false);
      }
      return;
    }

    final user = await _storage.getUser();
    if (user != null) {
      await _storage.joinRoom(room.id, user.id);
    }

    if (mounted) {
      // 방 상세로 바로 이동
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBeige,
      appBar: AppBar(
        title: const Text('초대받기'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // 아이콘
              Center(
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.accentPink.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.link,
                      size: 38, color: AppTheme.accentPink),
                ),
              ),
              const SizedBox(height: 24),
              const Text('초대받은 방에 입장해요',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('친구에게 받은 링크코드와 비밀번호를 입력하세요',
                  style: TextStyle(fontSize: 14, color: AppTheme.textLight),
                  textAlign: TextAlign.center),
              const SizedBox(height: 48),

              // 링크코드
              TextField(
                controller: _linkCtrl,
                textCapitalization: TextCapitalization.characters,
                maxLength: 8,
                decoration: const InputDecoration(
                  labelText: '링크코드 (8자리)',
                  hintText: 'ABCD1234',
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 16),

              // 비밀번호
              TextField(
                controller: _pwCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호 (4자리)',
                  hintText: '****',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                onSubmitted: (_) => _join(),
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _joining ? null : _join,
                child: _joining
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('입장하기'),
              ),
              const SizedBox(height: 32),

              // 안내 박스
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBeige,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(children: [
                  Icon(Icons.info_outline, color: AppTheme.textLight, size: 20),
                  SizedBox(height: 8),
                  Text(
                    '방 목록은 공개되지 않아요\n초대받은 링크코드와 비밀번호로만 입장 가능해요',
                    style: TextStyle(fontSize: 13, color: AppTheme.textLight),
                    textAlign: TextAlign.center,
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _linkCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }
}
