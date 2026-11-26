import 'package:flutter/material.dart';
import 'package:smart_home_automation_app/data/modals/room_model.dart';
import '../../../core/constants/app_colors.dart';
import '../ble/ble_setup_screen.dart';
import '../room/room_control_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Temporary dummy room list for UI preview
  final List<RoomModel> _rooms = [
    RoomModel(
      roomId: 'room_01',
      roomName: 'Bed Room 1',
      ownerId: 'uid_admin_101',
      isOnline: true,
      allowedUsers: {'uid_admin_101': true},
      switches: [
        SwitchItem(id: 'switch_1', name: 'Main Light', state: true),
        SwitchItem(id: 'switch_2', name: 'Ceiling Fan', state: false),
        SwitchItem(id: 'switch_3', name: 'Bed Lamp', state: false),
        SwitchItem(id: 'switch_4', name: 'AC Socket', state: false),
      ],
    ),
  ];

  void _showAddRoomDialog() {
    final roomNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('Add New Room', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: roomNameController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'e.g. Living Room',
            hintStyle: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (roomNameController.text.trim().isNotEmpty) {
                setState(() {
                  _rooms.add(
                    RoomModel(
                      roomId: 'room_0${_rooms.length + 1}',
                      roomName: roomNameController.text.trim(),
                      ownerId: 'uid_admin_101',
                      isOnline: false,
                      allowedUsers: {'uid_admin_101': true},
                      switches: [
                        SwitchItem(id: 'switch_1', name: 'Switch 1', state: false),
                        SwitchItem(id: 'switch_2', name: 'Switch 2', state: false),
                        SwitchItem(id: 'switch_3', name: 'Switch 3', state: false),
                        SwitchItem(id: 'switch_4', name: 'Switch 4', state: false),
                      ],
                    ),
                  );
                });
                // TODO: Save new room with 4 switches to Firebase via RoomCubit
              }
              Navigator.pop(context);
            },
            child: const Text('Create', style: TextStyle(color: AppColors.background)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'My Smart Home',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Configure ESP32 Wi-Fi (BLE)',
            icon: const Icon(Icons.bluetooth_searching_rounded, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BleSetupScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            onPressed: () {
              // TODO: Logout via AuthCubit
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        onPressed: _showAddRoomDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Room', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Accessible Rooms',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _rooms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final room = _rooms[index];
                  final activeCount = room.switches.where((s) => s.state).length;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    tileColor: AppColors.cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.meeting_room_rounded, color: AppColors.primary),
                    ),
                    title: Text(
                      room.roomName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '$activeCount of ${room.switches.length} switches ON',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoomControlScreen(room: room),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}