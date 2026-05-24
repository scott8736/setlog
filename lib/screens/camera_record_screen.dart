import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class CameraRecordScreen extends StatefulWidget {
  final String roomId;

  const CameraRecordScreen({super.key, required this.roomId});

  @override
  State<CameraRecordScreen> createState() => _CameraRecordScreenState();
}

class _CameraRecordScreenState extends State<CameraRecordScreen> with SingleTickerProviderStateMixin {
  final _storageService = StorageService();
  late AnimationController _countdownController;
  bool _isRecording = false;
  int _countdown = 2;

  @override
  void initState() {
    super.initState();
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _countdownController.addListener(() {
      final remaining = (2 - (_countdownController.value * 2)).ceil();
      if (remaining != _countdown) {
        setState(() => _countdown = remaining);
      }
    });

    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finishRecording();
      }
    });
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _countdown = 2;
    });
    _countdownController.forward(from: 0);
  }

  Future<void> _finishRecording() async {
    setState(() => _isRecording = false);

    // 실제 앱에서는 영상 파일을 서버에 업로드
    // 지금은 데모용 클립 생성
    final user = await _storageService.getUser();
    if (user == null) return;

    const uuid = Uuid();
    final clip = VideoClip(
      id: uuid.v4(),
      roomId: widget.roomId,
      userId: user.id,
      userName: user.nickname,
      recordedAt: DateTime.now(),
      thumbnailUrl: 'demo_thumbnail',
    );

    await _storageService.addClip(widget.roomId, clip);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('2초 영상이 방에 전송되었습니다!'),
          duration: Duration(seconds: 2),
        ),
      );

      // 클립을 결과로 반환
      Navigator.of(context).pop(clip);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // 카메라 프리뷰 영역 (데모용)
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[900],
              child: const Center(
                child: Icon(
                  Icons.videocam,
                  size: 80,
                  color: Colors.white54,
                ),
              ),
            ),
          ),

          // 녹화 카운트다운
          if (_isRecording)
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
                child: Center(
                  child: Text(
                    '$_countdown',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          // 하단 컨트롤
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isRecording ? null : _startRecording,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.red : Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: _isRecording
                      ? const SizedBox()
                      : const Icon(
                          Icons.videocam,
                          size: 40,
                          color: Colors.black,
                        ),
                ),
              ),
            ),
          ),

          // 안내 텍스트
          if (!_isRecording)
            const Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '2초 영상 촬영',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '버튼을 눌러 지금 이 순간을 기록하세요',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }
}
