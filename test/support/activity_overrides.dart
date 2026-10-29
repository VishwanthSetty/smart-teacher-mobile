import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:smart_teacher_mobile/src/core/sync/activity_cache_store.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_store.dart';
import 'package:smart_teacher_mobile/src/features/activity/data/history_repository.dart';
import 'package:smart_teacher_mobile/src/features/activity/data/progress_repository.dart';
import 'package:smart_teacher_mobile/src/features/home/data/home_repository.dart';
import 'package:smart_teacher_mobile/src/features/notifications/data/notification_repository.dart';
import 'package:smart_teacher_mobile/src/features/saved/data/bookmark_repository.dart';
import 'package:smart_teacher_mobile/src/features/saved/data/collection_repository.dart';
import 'package:smart_teacher_mobile/src/features/search/data/library_search_repository.dart';
import 'package:smart_teacher_mobile/src/features/tasks/data/student_task_repository.dart';
import 'package:smart_teacher_mobile/src/features/tasks/data/task_progress_repository.dart';
import 'package:smart_teacher_mobile/src/features/tasks/data/task_repository.dart';

import 'fake_bookmark_repository.dart';
import 'fake_collection_repository.dart';
import 'fake_history_repository.dart';
import 'fake_home_repository.dart';
import 'fake_notification_repository.dart';
import 'fake_progress_repository.dart';
import 'fake_search_repository.dart';
import 'fake_task_progress_repository.dart';
import 'fake_task_repository.dart';

/// Everything a test that pumps the real app needs so the learning-activity
/// layer stays off the network **and off native sqlite**.
///
/// The two store providers are the important ones. Their real implementations
/// read `appDatabaseProvider`, which opens a file through `path_provider` —
/// and `path_provider` has no implementation under `flutter test`, exactly
/// like the secure-storage channel the token fake exists to avoid. Overriding
/// the *interfaces* means the Drift database is never constructed at all,
/// rather than constructed and then failing asynchronously somewhere hard to
/// attribute.
///
/// Everything else here is a tab body. The shell's `IndexedStack` builds every
/// tab up front, so **every repository behind every tab of either shell must be
/// overridden or it goes straight to the network** — that now includes home,
/// tasks and saved. The bookmark repository is needed even off the Saved tab,
/// because the save toggle in the player and reader app bars reads the same
/// list.
///
/// The **notification** repository is in the same category and is easy to
/// miss: no tab renders the inbox, but the shell's app bar draws an unread
/// badge on every tab of both shells, and that badge watches the inbox list. A
/// test pumping the shell without this override fetches `/me/notifications` for
/// real.
List<Override> activityOverrides({
  InMemoryOutboxStore? outbox,
  InMemoryActivityCacheStore? cache,
  FakeProgressRepository? progress,
  FakeHistoryRepository? history,
  FakeHomeRepository? home,
  FakeBookmarkRepository? bookmarks,
  FakeCollectionRepository? collections,
  FakeLibrarySearchRepository? search,
  FakeTaskRepository? tasks,
  FakeStudentTaskRepository? studentTasks,
  FakeTaskProgressRepository? taskProgress,
  FakeNotificationRepository? notifications,
}) => <Override>[
  outboxStoreProvider.overrideWithValue(outbox ?? InMemoryOutboxStore()),
  activityCacheStoreProvider.overrideWithValue(
    cache ?? InMemoryActivityCacheStore(),
  ),
  progressRepositoryProvider.overrideWithValue(
    progress ?? FakeProgressRepository(),
  ),
  historyRepositoryProvider.overrideWithValue(
    history ?? FakeHistoryRepository(),
  ),
  homeRepositoryProvider.overrideWithValue(home ?? FakeHomeRepository()),
  bookmarkRepositoryProvider.overrideWithValue(
    bookmarks ?? FakeBookmarkRepository(),
  ),
  collectionRepositoryProvider.overrideWithValue(
    collections ?? FakeCollectionRepository(),
  ),
  librarySearchRepositoryProvider.overrideWithValue(
    search ?? FakeLibrarySearchRepository(),
  ),
  taskRepositoryProvider.overrideWithValue(tasks ?? FakeTaskRepository()),
  studentTaskRepositoryProvider.overrideWithValue(
    studentTasks ?? FakeStudentTaskRepository(),
  ),
  taskProgressRepositoryProvider.overrideWithValue(
    taskProgress ?? FakeTaskProgressRepository(),
  ),
  notificationRepositoryProvider.overrideWithValue(
    notifications ?? FakeNotificationRepository(),
  ),
];
