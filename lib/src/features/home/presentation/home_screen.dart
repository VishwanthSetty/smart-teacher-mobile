import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/section_header.dart';
import '../../classes/data/classes_repository.dart';
import '../../classes/domain/class_model.dart';
import 'widgets/stat_card.dart';

/// The dashboard landing screen: a greeting, headline stats and today's
/// schedule pulled from the classes data.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final classesAsync = ref.watch(classesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(classesProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          children: [
            Text(
              'Good morning, Alex',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              "Here's what's happening today.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            _StatsRow(classesAsync: classesAsync),
            const SizedBox(height: AppConstants.spacingLg),
            SectionHeader(
              title: "Today's schedule",
              actionLabel: 'View all',
              onAction: () => context.go(AppRoutes.classes),
            ),
            classesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppConstants.spacingXl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingLg,
                ),
                child: Text('Could not load schedule: $error'),
              ),
              data: (classes) => Column(
                children: [
                  for (final item in classes.take(3))
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.spacingSm,
                      ),
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.menu_book_outlined,
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                          title: Text(item.name),
                          subtitle: Text(item.schedule),
                          trailing: Text(
                            item.room,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          onTap: () => context.go(
                            '${AppRoutes.classes}/${AppRoutes.classDetail}',
                            extra: item,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.classesAsync});

  final AsyncValue<List<ClassModel>> classesAsync;

  @override
  Widget build(BuildContext context) {
    final classes = classesAsync.asData?.value;
    final classCount = classes?.length ?? 0;
    final studentCount = classes?.fold<int>(
          0,
          (sum, c) => sum + c.studentCount,
        ) ??
        0;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.class_outlined,
            value: '$classCount',
            label: 'Active classes',
            color: AppColors.seed,
          ),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        Expanded(
          child: StatCard(
            icon: Icons.groups_outlined,
            value: '$studentCount',
            label: 'Total students',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}
