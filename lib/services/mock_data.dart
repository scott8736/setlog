import 'package:flutter/material.dart';
import '../models/models.dart';

// ───────────────────────────────────────────
// 더미 데이터 서비스
// ───────────────────────────────────────────
class MockDataService {
  static final List<Color> _avatarColors = [
    const Color(0xFFE8A598),
    const Color(0xFF98B8E8),
    const Color(0xFF98E8B8),
    const Color(0xFFE8D498),
    const Color(0xFFB898E8),
    const Color(0xFFE898C8),
  ];

  static final List<String> _foodEmojis = ['☕', '🍜', '🥗', '🍱', '🥐', '🍵', '🫖', '🍳'];
  static final List<String> _placeEmojis = ['🏠', '📚', '🎵', '🌿', '🎨', '💻', '🛒', '🚶'];
  static final List<String> _moodEmojis = ['😌', '😄', '🤔', '😴', '🥰', '😎', '🫶', '✨'];

  // ── 현재 유저
  static final UserModel currentUser = UserModel(
    id: 'me',
    nickname: '나',
    age: 26,
    mbti: 'INFP',
    bio: '조용한 카페와 책을 좋아해요 ☕',
    tags: ['카페투어', '독서', '영화', '요리'],
    isOnline: true,
    lastActive: DateTime.now(),
  );

  // ── 더미 유저 목록
  static List<UserModel> get users => [
    UserModel(
      id: 'u1',
      nickname: '지현',
      age: 24,
      mbti: 'ENFP',
      bio: '그림 그리기와 산책을 좋아하는 자유로운 영혼 🎨',
      tags: ['그림', '산책', '카페', 'ENFP'],
      isOnline: true,
      lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    UserModel(
      id: 'u2',
      nickname: '민준',
      age: 28,
      mbti: 'INTJ',
      bio: '책이랑 커피면 충분해요 ☕📚',
      tags: ['독서', '커피', '음악감상', 'INTJ'],
      isOnline: false,
      lastActive: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    UserModel(
      id: 'u3',
      nickname: '서연',
      age: 25,
      mbti: 'ISFJ',
      bio: '요리하고 먹는 걸 좋아해요 🍳',
      tags: ['요리', '베이킹', '영화', 'ISFJ'],
      isOnline: true,
      lastActive: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    UserModel(
      id: 'u4',
      nickname: '도현',
      age: 27,
      mbti: 'ENTP',
      bio: '새로운 곳 탐험하기를 좋아하는 탐험가 🗺️',
      tags: ['여행', '사진', '음악', 'ENTP'],
      isOnline: false,
      lastActive: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    UserModel(
      id: 'u5',
      nickname: '유진',
      age: 23,
      mbti: 'INFJ',
      bio: '조용한 음악과 글쓰기를 즐겨요 🎵',
      tags: ['글쓰기', '음악', '카페', 'INFJ'],
      isOnline: true,
      lastActive: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  // ── 시간대별 클립 생성
  static List<ClipModel> _generateClips(String userId, String nickname, Color color) {
    final now = DateTime.now();
    final currentHour = now.hour;
    final clips = <ClipModel>[];
    final allEmojis = [..._foodEmojis, ..._placeEmojis, ..._moodEmojis];

    for (int h = 8; h <= currentHour; h++) {
      if (h % 3 != 0 && h != 8) continue; // 일부 시간대만
      clips.add(ClipModel(
        id: '${userId}_clip_$h',
        userId: userId,
        userNickname: nickname,
        recordedAt: DateTime(now.year, now.month, now.day, h),
        hour: h,
        avatarColor: color,
        emoji: allEmojis[(h + userId.hashCode) % allEmojis.length],
      ));
    }
    return clips;
  }

  // ── 방 목록
  static List<RoomModel> get rooms {
    final now = DateTime.now();
    return [
      RoomModel(
        id: 'r1',
        title: '지현이의 오늘 하루',
        creatorId: 'u1',
        creatorNickname: '지현',
        participantIds: ['me', 'u1'],
        createdAt: now.subtract(const Duration(hours: 6)),
        expiresAt: DateTime(now.year, now.month, now.day, 23, 59),
        todayClips: [
          ..._generateClips('me', '나', _avatarColors[0]),
          ..._generateClips('u1', '지현', _avatarColors[1]),
        ],
        inviteCode: 'SL-7K2P',
        roomType: 'solo',
      ),
      RoomModel(
        id: 'r2',
        title: '민준과 함께하는 일상',
        creatorId: 'me',
        creatorNickname: '나',
        participantIds: ['me', 'u2'],
        createdAt: now.subtract(const Duration(days: 1)),
        expiresAt: DateTime(now.year, now.month, now.day, 23, 59),
        todayClips: [
          ..._generateClips('me', '나', _avatarColors[0]),
          ..._generateClips('u2', '민준', _avatarColors[2]),
        ],
        inviteCode: 'SL-9M4Q',
        roomType: 'solo',
      ),
      RoomModel(
        id: 'r3',
        title: '일상 공유방',
        creatorId: 'u3',
        creatorNickname: '서연',
        participantIds: ['me', 'u3', 'u4', 'u5'],
        createdAt: now.subtract(const Duration(hours: 3)),
        expiresAt: DateTime(now.year, now.month, now.day, 23, 59),
        todayClips: [
          ..._generateClips('u3', '서연', _avatarColors[3]),
          ..._generateClips('u4', '도현', _avatarColors[4]),
          ..._generateClips('u5', '유진', _avatarColors[5]),
        ],
        inviteCode: 'SL-3R8W',
        roomType: 'group',
      ),
    ];
  }

  // ── 매칭 목록
  static List<MatchModel> get matches => [
    MatchModel(
      id: 'm1',
      user: users[0],
      compatibilityScore: 87,
      sharedTags: ['카페', '독서'],
      previewClips: _generateClips('u1', '지현', _avatarColors[1]),
      matchedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    MatchModel(
      id: 'm2',
      user: users[1],
      compatibilityScore: 74,
      sharedTags: ['독서', '커피'],
      previewClips: _generateClips('u2', '민준', _avatarColors[2]),
      matchedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MatchModel(
      id: 'm3',
      user: users[2],
      compatibilityScore: 91,
      sharedTags: ['요리', '영화'],
      previewClips: _generateClips('u3', '서연', _avatarColors[3]),
      matchedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    MatchModel(
      id: 'm4',
      user: users[4],
      compatibilityScore: 68,
      sharedTags: ['카페', '음악'],
      previewClips: _generateClips('u5', '유진', _avatarColors[5]),
      matchedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // ── 채팅방 목록
  static List<ChatRoomModel> get chatRooms => [
    ChatRoomModel(
      id: 'c1',
      otherUser: users[0],
      lastMessage: '오늘 그림 그리셨어요? 영상에서 봤는데 너무 예뻤어요 🎨',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 10)),
      unreadCount: 2,
      isMutualLike: true,
    ),
    ChatRoomModel(
      id: 'c2',
      otherUser: users[2],
      lastMessage: '요리 영상 보고 따라해봤는데 맛있었어요!',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
      isMutualLike: true,
    ),
    ChatRoomModel(
      id: 'c3',
      otherUser: users[1],
      lastMessage: '어떤 책 읽고 계세요?',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 1,
      isMutualLike: false,
    ),
  ];

  // ── 채팅 메시지
  static List<ChatMessage> getChatMessages(String chatRoomId) => [
    ChatMessage(
      id: 'msg1',
      senderId: 'u1',
      content: '안녕하세요! 셋로그 영상 잘 보고 있어요 😊',
      sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      isMe: false,
    ),
    ChatMessage(
      id: 'msg2',
      senderId: 'me',
      content: '안녕하세요~ 저도요! 오늘 카페 어디 가셨어요?',
      sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
      isMe: true,
    ),
    ChatMessage(
      id: 'msg3',
      senderId: 'u1',
      content: '홍대 근처 작은 카페요 ☕ 되게 아늑한 곳이에요',
      sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
      isMe: false,
    ),
    ChatMessage(
      id: 'msg4',
      senderId: 'me',
      content: '오 저도 홍대 자주 가는데! 이름이 어떻게 돼요?',
      sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      isMe: true,
    ),
    ChatMessage(
      id: 'msg5',
      senderId: 'u1',
      content: '몽환카페라고 아세요? 거기 분위기가 진짜 좋아요 🌿',
      sentAt: DateTime.now().subtract(const Duration(minutes: 20)),
      isMe: false,
    ),
    ChatMessage(
      id: 'msg6',
      senderId: 'u1',
      content: '오늘 그림 그리셨어요? 영상에서 봤는데 너무 예뻤어요 🎨',
      sentAt: DateTime.now().subtract(const Duration(minutes: 10)),
      isMe: false,
    ),
  ];

  // ── 오늘 남은 알림까지 시간(분)
  static int get minutesUntilNextNotification {
    final now = DateTime.now();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    return nextHour.difference(now).inMinutes;
  }

  // ── 오늘 몇 번 찍었는지
  static int get todayClipCount => 4;

  // ── 아바타 색상 가져오기
  static Color getAvatarColor(int index) =>
      _avatarColors[index % _avatarColors.length];
}
