import 'dart:math';
import 'package:uuid/uuid.dart';

// 방 (Room) 모델
class Room {
  final String id;
  final String name;
  final String linkCode;   // 공유용 링크 코드 (딥링크에 포함)
  final String password;   // 4자리 비밀번호
  final String creatorId;  // 방장 ID
  final DateTime createdAt;
  final List<String> memberIds;
  final List<VideoClip> clips;

  Room({
    required this.id,
    required this.name,
    required this.linkCode,
    required this.password,
    required this.creatorId,
    required this.createdAt,
    required this.memberIds,
    required this.clips,
  });

  bool get isOwner => true; // 내가 속한 방만 보임

  // 오늘 클립만 필터
  List<VideoClip> get todayClips {
    final today = DateTime.now();
    return clips.where((c) =>
      c.recordedAt.year == today.year &&
      c.recordedAt.month == today.month &&
      c.recordedAt.day == today.day
    ).toList();
  }

  // 당일 클립을 시간별로 그룹화
  Map<int, List<VideoClip>> get clipsByHour {
    final map = <int, List<VideoClip>>{};
    for (final clip in todayClips) {
      map.putIfAbsent(clip.recordedAt.hour, () => []).add(clip);
    }
    return map;
  }

  factory Room.create(String name, String creatorId) {
    const uuid = Uuid();
    return Room(
      id: uuid.v4(),
      name: name,
      linkCode: _generateLinkCode(),
      password: _generatePassword(),
      creatorId: creatorId,
      createdAt: DateTime.now(),
      memberIds: [creatorId],
      clips: [],
    );
  }

  // 8자리 대문자+숫자 랜덤 코드
  static String _generateLinkCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  // 4자리 숫자 비밀번호
  static String _generatePassword() {
    final rng = Random.secure();
    return (1000 + rng.nextInt(9000)).toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'linkCode': linkCode,
    'password': password,
    'creatorId': creatorId,
    'createdAt': createdAt.toIso8601String(),
    'memberIds': memberIds,
    'clips': clips.map((c) => c.toJson()).toList(),
  };

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['id'],
    name: json['name'],
    linkCode: json['linkCode'],
    password: json['password'],
    creatorId: json['creatorId'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
    memberIds: List<String>.from(json['memberIds']),
    clips: (json['clips'] as List).map((c) => VideoClip.fromJson(c)).toList(),
  );

  Room copyWith({List<VideoClip>? clips, List<String>? memberIds}) => Room(
    id: id,
    name: name,
    linkCode: linkCode,
    password: password,
    creatorId: creatorId,
    createdAt: createdAt,
    memberIds: memberIds ?? this.memberIds,
    clips: clips ?? this.clips,
  );
}

// 2~4초 영상 클립 모델
class VideoClip {
  final String id;
  final String roomId;
  final String userId;
  final String userName;
  final DateTime recordedAt;
  final String? videoPath;   // 로컬 저장 경로
  final String? memo;        // 짧은 텍스트 메모

  VideoClip({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.recordedAt,
    this.videoPath,
    this.memo,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'roomId': roomId,
    'userId': userId,
    'userName': userName,
    'recordedAt': recordedAt.toIso8601String(),
    'videoPath': videoPath,
    'memo': memo,
  };

  factory VideoClip.fromJson(Map<String, dynamic> json) => VideoClip(
    id: json['id'],
    roomId: json['roomId'],
    userId: json['userId'],
    userName: json['userName'],
    recordedAt: DateTime.parse(json['recordedAt']),
    videoPath: json['videoPath'],
    memo: json['memo'],
  );
}

// 사용자 모델
class AppUser {
  final String id;
  final String nickname;

  AppUser({required this.id, required this.nickname});

  Map<String, dynamic> toJson() => {'id': id, 'nickname': nickname};

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      AppUser(id: json['id'], nickname: json['nickname']);
}
