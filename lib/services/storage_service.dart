import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _userKey = 'current_user';
  static const String _roomsKey = 'my_rooms';

  // 현재 사용자 저장
  Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // 현재 사용자 불러오기
  Future<AppUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return AppUser.fromJson(jsonDecode(userJson));
  }

  // 방 목록 저장
  Future<void> saveRooms(List<Room> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    final roomsJson = rooms.map((r) => r.toJson()).toList();
    await prefs.setString(_roomsKey, jsonEncode(roomsJson));
  }

  // 방 목록 불러오기
  Future<List<Room>> getRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final roomsJson = prefs.getString(_roomsKey);
    if (roomsJson == null) return [];
    final List<dynamic> decoded = jsonDecode(roomsJson);
    return decoded.map((r) => Room.fromJson(r)).toList();
  }

  // 방 추가
  Future<void> addRoom(Room room) async {
    final rooms = await getRooms();
    rooms.add(room);
    await saveRooms(rooms);
  }

  // 방 업데이트
  Future<void> updateRoom(Room room) async {
    final rooms = await getRooms();
    final index = rooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      rooms[index] = room;
      await saveRooms(rooms);
    }
  }

  // 클립 추가
  Future<void> addClip(String roomId, VideoClip clip) async {
    final rooms = await getRooms();
    final roomIndex = rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex != -1) {
      final updatedClips = [...rooms[roomIndex].clips, clip];
      final updatedRoom = Room(
        id: rooms[roomIndex].id,
        name: rooms[roomIndex].name,
        linkCode: rooms[roomIndex].linkCode,
        password: rooms[roomIndex].password,
        createdAt: rooms[roomIndex].createdAt,
        memberIds: rooms[roomIndex].memberIds,
        clips: updatedClips,
      );
      await updateRoom(updatedRoom);
    }
  }
}
