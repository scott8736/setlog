import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

// 카메라 녹화 화면
// 웹: 시뮬레이션 UI (2~4초 카운트다운 + 메모 입력)
// 앱: 실제 카메라 연동 (Android/iOS)
class CameraRecordScreen extends StatefulWidget {
  final String roomId;
  const CameraRecordScreen({super.key, required this.roomId});

  @override
  State<CameraRecordScreen> createState() => _CameraRecordScreenState();
}

class _CameraRecordScreenState extends State<CameraRecordScreen>
    with SingleTickerProviderStateMixin {
  final _storage = StorageService();
  late AnimationController _animCtrl;

  // 상태
  RecordState _state = RecordState.ready;
  int _seconds = 0;
  int _selectedDuration = 2; // 2 or 4초
  String? _memo;
  VideoClip? _recorded;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this);
  }

  void _startRecord() {
    setState(() {
      _state = RecordState.countdown;
      _seconds = 3; // 3-2-1 카운트다운
    });
    _runCountdown();
  }

  void _runCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _seconds--);
      if (_seconds > 0) {
        _runCountdown();
      } else {
        _startActualRecord();
      }
    });
  }

  void _startActualRecord() {
    setState(() {
      _state = RecordState.recording;
      _seconds = _selectedDuration;
    });
    _runRecord();
  }

  void _runRecord() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _seconds--);
      if (_seconds > 0) {
        _runRecord();
      } else {
        setState(() => _state = RecordState.memo);
      }
    });
  }

  Future<void> _send() async {
    final user = await _storage.getUser();
    if (user == null) return;

    const uuid = Uuid();
    final clip = VideoClip(
      id: uuid.v4(),
      roomId: widget.roomId,
      userId: user.id,
      userName: user.nickname,
      recordedAt: DateTime.now(),
      videoPath: 'demo_${uuid.v4()}', // 실제 앱에서는 로컬 파일 경로
      memo: _memo?.isNotEmpty == true ? _memo : null,
    );

    await _storage.addClip(clip);
    setState(() {
      _recorded = clip;
      _state = RecordState.done;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case RecordState.ready:
        return _buildReady();
      case RecordState.countdown:
        return _buildCountdown();
      case RecordState.recording:
        return _buildRecording();
      case RecordState.memo:
        return _buildMemo();
      case RecordState.done:
        return _buildDone();
    }
  }

  // ── 준비 화면 ──
  Widget _buildReady() {
    return Column(children: [
      // 닫기
      Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      const Spacer(),

      // 카메라 뷰파인더 (데모)
      Container(
        width: double.infinity,
        height: 320,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_outlined, size: 64, color: Colors.white38),
            SizedBox(height: 12),
            Text('카메라 영역', style: TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
      ),
      const SizedBox(height: 32),

      // 촬영 시간 선택
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _durationBtn(2),
        const SizedBox(width: 12),
        _durationBtn(4),
      ]),
      const SizedBox(height: 32),

      // 촬영 버튼
      GestureDetector(
        onTap: _startRecord,
        child: Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: const Icon(Icons.fiber_manual_record,
              size: 48, color: AppTheme.accentPink),
        ),
      ),
      const SizedBox(height: 12),
      const Text('${2}초 또는 4초 촬영',
          style: TextStyle(color: Colors.white54, fontSize: 13)),
      const Spacer(),
    ]);
  }

  Widget _durationBtn(int sec) {
    final selected = _selectedDuration == sec;
    return GestureDetector(
      onTap: () => setState(() => _selectedDuration = sec),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accentPink : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('$sec초',
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  // ── 카운트다운 ──
  Widget _buildCountdown() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$_seconds',
            style: const TextStyle(fontSize: 120, fontWeight: FontWeight.bold,
                color: Colors.white)),
        const Text('준비하세요!',
            style: TextStyle(fontSize: 20, color: Colors.white70)),
      ]),
    );
  }

  // ── 녹화 중 ──
  Widget _buildRecording() {
    return Column(children: [
      const Spacer(),
      Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: 120, height: 120,
          child: CircularProgressIndicator(
            value: _seconds / _selectedDuration,
            strokeWidth: 6,
            color: AppTheme.accentPink,
            backgroundColor: Colors.white24,
          ),
        ),
        Text('$_seconds',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold,
                color: Colors.white)),
      ]),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 10, height: 10,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.red)),
        const SizedBox(width: 8),
        const Text('녹화 중 • 무음 카메라',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ]),
      const Spacer(),
    ]);
  }

  // ── 메모 입력 ──
  Widget _buildMemo() {
    final ctrl = TextEditingController();
    return Column(children: [
      const SizedBox(height: 60),
      const Icon(Icons.check_circle_outline, size: 72, color: AppTheme.accentPink),
      const SizedBox(height: 20),
      const Text('촬영 완료!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
              color: Colors.white)),
      const SizedBox(height: 8),
      const Text('짧은 한 줄을 남겨보세요 (선택)',
          style: TextStyle(color: Colors.white54)),
      const SizedBox(height: 32),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: TextField(
          controller: ctrl,
          maxLength: 30,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '지금 이 순간은...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white12,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (v) => _memo = v,
        ),
      ),
      const SizedBox(height: 24),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ElevatedButton(
          onPressed: () {
            _memo = ctrl.text.trim();
            _send();
          },
          child: const Text('방에 전송하기'),
        ),
      ),
      TextButton(
        onPressed: _send,
        child: const Text('메모 없이 전송',
            style: TextStyle(color: Colors.white54)),
      ),
    ]);
  }

  // ── 전송 완료 ──
  Widget _buildDone() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.cloud_done_outlined, size: 80, color: Colors.greenAccent),
      const SizedBox(height: 24),
      const Text('방에 전송되었어요!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
              color: Colors.white)),
      if (_recorded?.memo != null) ...[
        const SizedBox(height: 12),
        Text('"${_recorded!.memo}"',
            style: const TextStyle(color: Colors.white70, fontSize: 16)),
      ],
      const SizedBox(height: 40),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, _recorded),
          child: const Text('방으로 돌아가기'),
        ),
      ),
    ]);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }
}

enum RecordState { ready, countdown, recording, memo, done }
