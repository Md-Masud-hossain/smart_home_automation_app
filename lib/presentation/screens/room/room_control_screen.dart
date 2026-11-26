import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/room_cubit/room_cubit.dart';
import '../../../logic/room_cubit/room_state.dart';
import '../../widgets/switch_card_widget.dart';
import 'manage_access_screen.dart';

class RoomControlScreen extends StatelessWidget {
  final String roomId;

  const RoomControlScreen({super.key, required this.roomId});

  void _renameSwitchDialog(
    BuildContext context,
    String switchId,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<RoomCubit>().renameSwitch(roomId, switchId, controller.text);
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Save', style: TextStyle(color: AppColors.background)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomCubit, RoomState>(
      builder: (context, state) {
        if (state is! RoomLoaded) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final roomIndex = state.rooms.indexWhere((r) => r.roomId == roomId);
        if (roomIndex == -1) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('Room not found', style: TextStyle(color: AppColors.textPrimary))),
          );
        }

        final room = state.rooms[roomIndex];

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
                  room.roomName,
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
                      color: room.isOnline ? AppColors.accent : AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      room.isOnline ? 'ESP32 Online' : 'ESP32 Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: room.isOnline ? AppColors.accent : AppColors.error,
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
                      builder: (_) => ManageAccessScreen(roomId: room.roomId),
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
                    itemCount: room.switches.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final sw = room.switches[index];
                      return SwitchCardWidget(
                        switchItem: sw,
                        onToggle: () {
                          context.read<RoomCubit>().toggleSwitch(
                                room.roomId,
                                sw.id,
                                !sw.state,
                              );
                        },
                        onLongPress: () => _renameSwitchDialog(context, sw.id, sw.name),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}