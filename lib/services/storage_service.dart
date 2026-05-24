import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _userKey = 'current_user';
  static const String _roomsKey = 'my_rooms';

  // ───── 사용자 ─────
  Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<AppUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_userKey);
    if (s == null) return null;
    return AppUser.fromJson(jsonDecode(s));
  }

  // ───── 방 ─────
  Future<List<Room>> getRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_roomsKey);
    if (s == null) return [];
    final List<dynamic> list = jsonDecode(s);
    return list.map((e) => Room.fromJson(e)).toList();
  }

  Future<void> _saveRooms(List<Room> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roomsKey, jsonEncode(rooms.map((r) => r.toJson()).toList()));
  }

  Future<Room> addRoom(Room room) async {
    final rooms = await getRooms();
    rooms.add(room);
    await _saveRooms(rooms);
    return room;
  }

  // 링크코드 + 비번으로 방 찾기 (초대 입장용)
  Future<Room?> findRoomByLinkAndPassword(String linkCode, String password) async {
    final rooms = await getRooms();
    try {
      return rooms.firstWhere(
        (r) => r.linkCode == linkCode && r.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  // 링크코드만으로 방 찾기 (딥링크 클릭 시)
  Future<Room?> findRoomByLinkCode(String linkCode) async {
    final rooms = await getRooms();
    try {
      return rooms.firstWhere((r) => r.linkCode == linkCode);
    } catch (_) {
      return null;
    }
  }

  // 방에 멤버 추가
  Future<void> joinRoom(String roomId, String userId) async {
    final rooms = await getRooms();
    final idx = rooms.indexWhere((r) => r.id == roomId);
    if (idx != -1 && !rooms[idx].memberIds.contains(userId)) {
      final updated = rooms[idx].copyWith(
        memberIds: [...rooms[idx].memberIds, userId],
      );
      rooms[idx] = updated;
      await _saveRooms(rooms);
    }
  }

  // 클립 추가
  Future<void> addClip(VideoClip clip) async {
    final rooms = await getRooms();
    final idx = rooms.indexWhere((r) => r.id == clip.roomId);
    if (idx != -1) {
      final updated = rooms[idx].copyWith(
        clips: [...rooms[idx].clips, clip],
      );
      rooms[idx] = updated;
      await _saveRooms(rooms);
    }
  }

  // 당일이 아닌 클립 자동 삭제 (자정 처리)
  Future<void> deleteOldClips() async {
    final rooms = await getRooms();
    final today = DateTime.now();
    bool changed = false;

    final updated = rooms.map((room) {
      final filtered = room.clips.where((c) =>
        c.recordedAt.year == today.year &&
        c.recordedAt.month == today.month &&
        c.recordedAt.day == today.day
      ).toList();

      if (filtered.length != room.clips.length) {
        changed = true;
        return room.copyWith(clips: filtered);
      }
      return room;
    }).toList();

    if (changed) await _saveRooms(updated);
  }

  // 특정 방 가져오기
  Future<Room?> getRoom(String roomId) async {
    final rooms = await getRooms();
    try {
      return rooms.firstWhere((r) => r.id == roomId);
    } catch (_) {
      return null;
    }
  }
}
