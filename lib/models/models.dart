import 'package:flutter/material.dart';

// ───────────────────────────────────────────
// 사용자 모델
// ───────────────────────────────────────────
class UserModel {
  final String id;
  final String nickname;
  final int age;
  final String mbti;
  final String bio;
  final String? profileVideoUrl;
  final List<String> tags;
  final bool isOnline;
  final DateTime lastActive;

  UserModel({
    required this.id,
    required this.nickname,
    required this.age,
    required this.mbti,
    required this.bio,
    this.profileVideoUrl,
    required this.tags,
    this.isOnline = false,
    required this.lastActive,
  });
}

// ───────────────────────────────────────────
// 클립(2초 영상) 모델
// ───────────────────────────────────────────
class ClipModel {
  final String id;
  final String userId;
  final String userNickname;
  final DateTime recordedAt;
  final int hour; // 0~23
  final String? thumbnailUrl;
  final Color avatarColor;
  final String emoji;

  ClipModel({
    required this.id,
    required this.userId,
    required this.userNickname,
    required this.recordedAt,
    required this.hour,
    this.thumbnailUrl,
    required this.avatarColor,
    required this.emoji,
  });
}

// ───────────────────────────────────────────
// 방(Room) 모델
// ───────────────────────────────────────────
class RoomModel {
  final String id;
  final String title;
  final String creatorId;
  final String creatorNickname;
  final List<String> participantIds;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<ClipModel> todayClips;
  final bool isActive;
  final String inviteCode;
  final String roomType; // 'solo' | 'group'

  RoomModel({
    required this.id,
    required this.title,
    required this.creatorId,
    required this.creatorNickname,
    required this.participantIds,
    required this.createdAt,
    required this.expiresAt,
    required this.todayClips,
    this.isActive = true,
    required this.inviteCode,
    this.roomType = 'solo',
  });

  int get participantCount => participantIds.length;

  double get completionRate {
    final currentHour = DateTime.now().hour;
    if (currentHour == 0) return 0;
    return todayClips.length / currentHour;
  }
}

// ───────────────────────────────────────────
// 매칭 모델
// ───────────────────────────────────────────
class MatchModel {
  final String id;
  final UserModel user;
  final int compatibilityScore;
  final List<String> sharedTags;
  final List<ClipModel> previewClips;
  final bool isLiked;
  final DateTime matchedAt;

  MatchModel({
    required this.id,
    required this.user,
    required this.compatibilityScore,
    required this.sharedTags,
    required this.previewClips,
    this.isLiked = false,
    required this.matchedAt,
  });
}

// ───────────────────────────────────────────
// 채팅 메시지 모델
// ───────────────────────────────────────────
class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final bool isMe;
  final String? clipId;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.isMe,
    this.clipId,
  });
}

// ───────────────────────────────────────────
// 채팅방 모델
// ───────────────────────────────────────────
class ChatRoomModel {
  final String id;
  final UserModel otherUser;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool isMutualLike;

  ChatRoomModel({
    required this.id,
    required this.otherUser,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.isMutualLike = false,
  });
}
