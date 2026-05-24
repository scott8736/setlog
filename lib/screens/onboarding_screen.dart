import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nicknameController = TextEditingController();
  final _storageService = StorageService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkExistingUser();
  }

  Future<void> _checkExistingUser() async {
    final user = await _storageService.getUser();
    if (user != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNickname() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해주세요')),
      );
      return;
    }

    const uuid = Uuid();
    final user = AppUser(
      id: uuid.v4(),
      nickname: _nicknameController.text.trim(),
    );

    await _storageService.saveUser(user);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'SETLOG',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '매시간 2초, 하루를 기록하다',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: '닉네임',
                  hintText: '사용할 닉네임을 입력하세요',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveNickname,
                child: const Text('시작하기'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }
}
