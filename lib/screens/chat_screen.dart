import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/mock_data.dart';
import '../widgets/common_widgets.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatRoomModel> _chatRooms = MockDataService.chatRooms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(child: _buildChatList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💬 메시지', style: AppTextStyles.titleLarge),
          const SizedBox(height: 4),
          Text(
            '하루를 공유한 사람들과 대화해요',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    if (_chatRooms.isEmpty) {
      return const EmptyStateWidget(
        emoji: '💬',
        title: '아직 대화가 없어요',
        subtitle: '매칭 화면에서 마음에 드는 사람에게\n채팅을 시작해보세요!',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _chatRooms.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) => _buildChatTile(_chatRooms[index]),
    );
  }

  Widget _buildChatTile(ChatRoomModel chatRoom) {
    final userIdx = MockDataService.users
        .indexWhere((u) => u.id == chatRoom.otherUser.id);
    final color = MockDataService.getAvatarColor(userIdx);
    final timeStr = _formatTime(chatRoom.lastMessageAt);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(chatRoom: chatRoom),
        ),
      ),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // 아바타
            Stack(
              children: [
                ProfileAvatar(
                  nickname: chatRoom.otherUser.nickname,
                  color: color,
                  size: 52,
                  isOnline: chatRoom.otherUser.isOnline,
                ),
                if (chatRoom.isMutualLike)
                  Positioned(
                    right: -2, top: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Center(
                        child: Text('💕', style: TextStyle(fontSize: 9)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(chatRoom.otherUser.nickname,
                          style: AppTextStyles.titleMedium.copyWith(fontSize: 15)),
                      if (chatRoom.isMutualLike) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            '서로 좋아요',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDeep,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(timeStr, style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatRoom.lastMessage,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: chatRoom.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: chatRoom.unreadCount > 0
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chatRoom.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${chatRoom.unreadCount}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}
