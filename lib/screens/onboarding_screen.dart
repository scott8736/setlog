import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = TextEditingController();
  final _storage = StorageService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    // 당일 아닌 클립 자동 삭제
    await _storage.deleteOldClips();
    final user = await _storage.getUser();
    if (user != null && mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _start() async {
    final nick = _controller.text.trim();
    if (nick.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('닉네임을 입력해주세요')));
      return;
    }
    const uuid = Uuid();
    await _storage.saveUser(AppUser(id: uuid.v4(), nickname: nick));
    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // 로고
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.accentPink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.video_camera_back_outlined,
                    size: 40, color: AppTheme.accentPink),
              ),
              const SizedBox(height: 32),
              const Text('SETLOG LOVABLE',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                      color: AppTheme.textDark, letterSpacing: 1)),
              const SizedBox(height: 8),
              const Text('매시간 2초, 오늘 하루를 함께 기록해요',
                  style: TextStyle(fontSize: 15, color: AppTheme.textLight)),
              const SizedBox(height: 60),
              TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '닉네임을 입력하세요',
                ),
                onSubmitted: (_) => _start(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _start,
                child: const Text('시작하기'),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
