import 'package:flutter/material.dart';
import 'package:smart_home_automation_app/data/modals/room_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/switch_card_widget.dart';
import 'manage_access_screen.dart';

class RoomControlScreen extends StatefulWidget {
  final RoomModel room;

  const RoomControlScreen({super.key, required this.room});

  @override
  State<RoomControlScreen> createState() => _RoomControlScreenState();
}

class _RoomControlScreenState extends State<RoomControlScreen> {
  late List<SwitchItem> _switches;

  @override
  void initState() {
    super.initState();
    _switches = List.from(widget.room.switches);
  }

  void _toggleSwitch(int index) {
    setState(() {
      final current = _switches[index];
      _switches[index] = SwitchItem(
        id: current.id,
        name: current.name,
        state: !current.state,
      );
    });
    // TODO: Connect RoomCubit to update Firebase Realtime Database
  }

  void _renameSwitchDialog(int index) {
    final controller = TextEditingController(text: _switches[index].name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('Rename Switch', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'e.g. Ceiling Fan',
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
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _switches[index] = SwitchItem(
                    id: _switches[index].id,
                    name: controller.text.trim(),
                    state: _switches[index].state,
                  );
                });
                // TODO: Update name in Firebase via RoomCubit
              }
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: AppColors.background)),
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
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.room.roomName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: widget.room.isOnline ? AppColors.accent : AppColors.error,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.room.isOnline ? 'ESP32 Online' : 'ESP32 Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.room.isOnline ? AppColors.accent : AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Manage User Access',
            icon: const Icon(Icons.group_add_rounded, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManageAccessScreen(room: widget.room),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Room Switches (Long press to rename)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: _switches.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  return SwitchCardWidget(
                    switchItem: _switches[index],
                    onToggle: () => _toggleSwitch(index),
                    onLongPress: () => _renameSwitchDialog(index),
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