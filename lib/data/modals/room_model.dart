class SwitchItem {
  final String id;     // switch_1, switch_2, switch_3, switch_4
  final String name;   // Light, Fan, etc.
  final bool state;    // true = ON, false = OFF

  SwitchItem({
    required this.id,
    required this.name,
    required this.state,
  });

  factory SwitchItem.fromMap(String id, Map<dynamic, dynamic> map) {
    return SwitchItem(
      id: id,
      name: map['name'] ?? 'Switch',
      state: map['state'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'state': state,
    };
  }
}

class RoomModel {
  final String roomId;
  final String roomName;
  final String ownerId;
  final bool isOnline;
  final Map<String, bool> allowedUsers;
  final List<SwitchItem> switches;

  RoomModel({
    required this.roomId,
    required this.roomName,
    required this.ownerId,
    required this.isOnline,
    required this.allowedUsers,
    required this.switches,
  });

  factory RoomModel.fromMap(String roomId, Map<dynamic, dynamic> map) {
    // Allowed users parsing
    final rawUsers = map['allowedUsers'] as Map<dynamic, dynamic>? ?? {};
    final parsedUsers = rawUsers.map((key, value) => MapEntry(key.toString(), value == true));

    // 4 Switches parsing (sorted by switch_1 to switch_4)
    final rawSwitches = map['switches'] as Map<dynamic, dynamic>? ?? {};
    final List<SwitchItem> parsedSwitches = [];
    
    final sortedKeys = rawSwitches.keys.toList()..sort();
    for (var key in sortedKeys) {
      parsedSwitches.add(SwitchItem.fromMap(key.toString(), rawSwitches[key]));
    }

    return RoomModel(
      roomId: roomId,
      roomName: map['roomName'] ?? 'Unnamed Room',
      ownerId: map['ownerId'] ?? '',
      isOnline: map['isOnline'] ?? false,
      allowedUsers: parsedUsers,
      switches: parsedSwitches,
    );
  }
}