import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_home_automation_app/data/modals/room_model.dart';

class RoomRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // ১. বর্তমান ইউজারের অ্যাক্সেস থাকা সব রুমের রিয়েল-টাইম স্ট্রিম
  Stream<List<RoomModel>> getUserRoomsStream() {
    final uid = currentUserId;
    if (uid.isEmpty) return Stream.value([]);

    return _db.child('rooms').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      final List<RoomModel> accessibleRooms = [];
      data.forEach((key, value) {
        final roomMap = value as Map<dynamic, dynamic>;
        final allowedUsers = roomMap['allowedUsers'] as Map<dynamic, dynamic>? ?? {};

        // শুধু সেই রুমগুলোই দেখাবে যেখানে এই ইউজারের অ্যাক্সেস (true) আছে
        if (allowedUsers[uid] == true) {
          accessibleRooms.add(RoomModel.fromMap(key.toString(), roomMap));
        }
      });

      return accessibleRooms;
    });
  }

  // ২. নতুন রুম ও ডিফল্ট ৪টি সুইচ তৈরি করা
  Future<void> createRoom(String roomName) async {
    final uid = currentUserId;
    if (uid.isEmpty) throw Exception('User not logged in');

    final newRoomRef = _db.child('rooms').push();
    await newRoomRef.set({
      'roomName': roomName.trim(),
      'ownerId': uid,
      'isOnline': false, // ESP32 কানেক্ট হলে এটি true হবে
      'allowedUsers': {
        uid: true,
      },
      'switches': {
        'switch_1': {'name': 'Main Light', 'state': false},
        'switch_2': {'name': 'Ceiling Fan', 'state': false},
        'switch_3': {'name': 'Bed Lamp', 'state': false},
        'switch_4': {'name': 'AC / Socket', 'state': false},
      },
    });
  }

  // ৩. ৪টি সুইচের যেকোনো একটি অন/অফ টগল করা
  Future<void> toggleSwitch({
    required String roomId,
    required String switchId,
    required bool newState,
  }) async {
    await _db
        .child('rooms')
        .child(roomId)
        .child('switches')
        .child(switchId)
        .update({'state': newState});
  }

  // ৪. সুইচের নাম পরিবর্তন করা
  Future<void> renameSwitch({
    required String roomId,
    required String switchId,
    required String newName,
  }) async {
    await _db
        .child('rooms')
        .child(roomId)
        .child('switches')
        .child(switchId)
        .update({'name': newName.trim()});
  }

  // ৫. ইমেইল দিয়ে অন্য ইউজারকে রুমের অ্যাক্সেস দেওয়া (Multi-User Access)
  Future<void> addMemberByEmail({
    required String roomId,
    required String email,
  }) async {
    final targetEmail = email.trim().toLowerCase();
    final usersSnapshot = await _db.child('users').get();

    if (!usersSnapshot.exists || usersSnapshot.value == null) {
      throw Exception('No registered users found.');
    }

    String? targetUid;
    final usersMap = usersSnapshot.value as Map<dynamic, dynamic>;

    usersMap.forEach((uid, userData) {
      final userMap = userData as Map<dynamic, dynamic>;
      if ((userMap['email'] ?? '').toString().toLowerCase() == targetEmail) {
        targetUid = uid.toString();
      }
    });

    if (targetUid == null) {
      throw Exception('No account found with this email. Ask them to sign up first.');
    }

    await _db
        .child('rooms')
        .child(roomId)
        .child('allowedUsers')
        .update({targetUid!: true});
  }

  // ৬. কোনো মেম্বারের অ্যাক্সেস রিমুভ করা
  Future<void> removeMember({
    required String roomId,
    required String memberUid,
  }) async {
    await _db
        .child('rooms')
        .child(roomId)
        .child('allowedUsers')
        .child(memberUid)
        .remove();
  }
}