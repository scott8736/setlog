import 'package:uuid/uuid.dart';

// 방 (Room) 모델
class Room {
  final String id;
  final String name;
  final String linkCode; // 공유용 링크 코드
  final String password; // 4자리 비밀번호
  final DateTime createdAt;
  final List<String> memberIds;
  final List<VideoClip> clips;

  Room({
    required this.id,
    required this.name,
    required this.linkCode,
    required this.password,
    required this.createdAt,
    required this.memberIds,
    required this.clips,
  });

  factory Room.create(String name, String creatorId) {
    const uuid = Uuid();
    return Room(
      id: uuid.v4(),
      name: name,
      linkCode: _generateLinkCode(),
      password: _generatePassword(),
      createdAt: DateTime.now(),
      memberIds: [creatorId],
      clips: [],
    );
  }

  static String _generateLinkCode() {
    // 8자리 랜덤 코드 (예: ABC12345)
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[(DateTime.now().microsecond + index) % chars.length]).join();
  }

  static String _generatePassword() {
    // 4자리 숫자 비밀번호
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    return random.toString().padLeft(4, '0');
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'linkCode': linkCode,
    'password': password,
    'createdAt': createdAt.toIso8601String(),
    'memberIds': memberIds,
    'clips': clips.map((c) => c.toJson()).toList(),
  };

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['id'],
    name: json['name'],
    linkCode: json['linkCode'],
    password: json['password'],
    createdAt: DateTime.parse(json['createdAt']),
    memberIds: List<String>.from(json['memberIds']),
    clips: (json['clips'] as List).map((c) => VideoClip.fromJson(c)).toList(),
  );
}

// 2초 영상 클립 모델
class VideoClip {
  final String id;
  final String roomId;
  final String userId;
  final String userName;
  final DateTime recordedAt;
  final String? videoUrl; // 실제 앱에서는 영상 URL
  final String thumbnailUrl;

  VideoClip({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.recordedAt,
    this.videoUrl,
    required this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'roomId': roomId,
    'userId': userId,
    'userName': userName,
    'recordedAt': recordedAt.toIso8601String(),
    'videoUrl': videoUrl,
    'thumbnailUrl': thumbnailUrl,
  };

  factory VideoClip.fromJson(Map<String, dynamic> json) => VideoClip(
    id: json['id'],
    roomId: json['roomId'],
    userId: json['userId'],
    userName: json['userName'],
    recordedAt: DateTime.parse(json['recordedAt']),
    videoUrl: json['videoUrl'],
    thumbnailUrl: json['thumbnailUrl'],
  );
}

// 사용자 모델
class AppUser {
  final String id;
  final String nickname;

  AppUser({
    required this.id,
    required this.nickname,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'],
    nickname: json['nickname'],
  );
}
