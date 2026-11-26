import 'package:flutter/material.dart';
import 'package:smart_home_automation_app/data/modals/room_model.dart';
import '../../../core/constants/app_colors.dart';

class ManageAccessScreen extends StatefulWidget {
  final RoomModel room;

  const ManageAccessScreen({super.key, required this.room});

  @override
  State<ManageAccessScreen> createState() => _ManageAccessScreenState();
}

class _ManageAccessScreenState extends State<ManageAccessScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _grantAccess() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) return;

    // TODO: Find user UID by email in Firebase and add to room's allowedUsers
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Access granted to $email')),
    );
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final userIds = widget.room.allowedUsers.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          '${widget.room.roomName} - Access',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Share Room Control',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Enter member email',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _grantAccess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Authorized Users',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: userIds.length,
                itemBuilder: (context, index) {
                  final uid = userIds[index];
                  final isOwner = uid == widget.room.ownerId;

                  return Card(
                    color: AppColors.cardBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: AppColors.primary),
                      title: Text(uid, style: const TextStyle(color: AppColors.textPrimary)),
                      subtitle: Text(
                        isOwner ? 'Admin / Owner' : 'Member',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      trailing: isOwner
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                              onPressed: () {
                                // TODO: Remove user from allowedUsers via RoomCubit
                              },
                            ),
                    ),
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