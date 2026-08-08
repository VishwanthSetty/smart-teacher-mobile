import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/class_model.dart';

/// Read-only detail view for a single [ClassModel].
class ClassDetailScreen extends StatelessWidget {
  const ClassDetailScreen({super.key, required this.classItem});

  final ClassModel classItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(classItem.name)),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.menu_book_outlined,
                      size: 28,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classItem.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingXs),
                        Text(
                          '${classItem.subject} · ${classItem.grade}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          _DetailTile(
            icon: Icons.groups_outlined,
            label: 'Students',
            value: '${classItem.studentCount}',
          ),
          _DetailTile(
            icon: Icons.schedule_outlined,
            label: 'Schedule',
            value: classItem.schedule,
          ),
          _DetailTile(
            icon: Icons.meeting_room_outlined,
            label: 'Room',
            value: classItem.room,
          ),
          _DetailTile(
            icon: Icons.subject_outlined,
            label: 'Subject',
            value: classItem.subject,
          ),
          const SizedBox(height: AppConstants.spacingLg),
          FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attendance — coming soon')),
            ),
            icon: const Icon(Icons.how_to_reg_outlined),
            label: const Text('Take attendance'),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodySmall),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
