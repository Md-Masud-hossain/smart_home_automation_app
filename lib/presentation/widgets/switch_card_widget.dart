import 'package:flutter/material.dart';
import 'package:smart_home_automation_app/data/modals/room_model.dart';
import '../../core/constants/app_colors.dart';

class SwitchCardWidget extends StatelessWidget {
  final SwitchItem switchItem;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;

  const SwitchCardWidget({
    super.key,
    required this.switchItem,
    required this.onToggle,
    required this.onLongPress,
  });

  IconData _getSwitchIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('fan')) return Icons.wind_power_rounded;
    if (lower.contains('lamp') || lower.contains('bed')) return Icons.bedtime_rounded;
    if (lower.contains('ac') || lower.contains('socket')) return Icons.power_rounded;
    return Icons.lightbulb_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final bool isOn = switchItem.state;

    return GestureDetector(
      onTap: onToggle,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOn ? AppColors.primary.withValues(alpha: 0.15) : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOn ? AppColors.primary : Colors.white10,
            width: isOn ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isOn ? AppColors.primary : AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getSwitchIcon(switchItem.name),
                    color: isOn ? AppColors.background : AppColors.textSecondary,
                    size: 26,
                  ),
                ),
                Switch(
                  value: isOn,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switchItem.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOn ? 'ON' : 'OFF',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isOn ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}