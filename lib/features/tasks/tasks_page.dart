import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:uniguide/core/content/student_guide_content.dart';
import 'package:uniguide/core/localization/ui_texts.dart';
import 'package:uniguide/features/guides/guide_detail_page.dart';
import 'package:uniguide/features/tasks/task_repository.dart';
import 'package:uniguide/l10n/app_localizations.dart';

enum _TaskFilter { all, active, completed, custom, dueSoon, overdue }

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _searchController = TextEditingController();
  final _repository = TaskRepository.instance;

  Locale? _loadedLocale;
  TaskDashboard? _dashboard;
  bool _loading = true;
  String _query = '';
  _TaskFilter _filter = _TaskFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_loadedLocale?.languageCode != locale.languageCode ||
        _loadedLocale?.countryCode != locale.countryCode) {
      _loadedLocale = locale;
      _load();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final locale = Localizations.localeOf(context);
    final dashboard = await _repository.load(locale);
    if (!mounted) return;
    setState(() {
      _dashboard = dashboard;
      _loading = false;
    });
  }

  Future<void> _toggleStatus(TaskRecord task) async {
    final nextStatus = task.isDone ? TaskStatus.pending : TaskStatus.done;
    await _repository.setStatus(task.id, nextStatus);
    await _load();
  }

  Future<void> _setStatus(TaskRecord task, TaskStatus status) async {
    await _repository.setStatus(task.id, status);
    await _load();
  }

  Future<void> _openTaskEditor({TaskRecord? task}) async {
    final result = await showModalBottomSheet<TaskRecord>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _TaskEditorSheet(initialTask: task),
    );

    if (result != null) {
      await _repository.saveCustomTask(result);
      await _load();
    }
  }

  Future<void> _deleteCustomTask(TaskRecord task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_text(context, en: 'Delete task', ar: 'حذف المهمة')),
        content: Text(
          _text(
            context,
            en: 'This custom task will be removed from the app.',
            ar: 'ستتم إزالة هذه المهمة المخصصة من التطبيق.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_text(context, en: 'Delete', ar: 'حذف')),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _repository.deleteCustomTask(task.id);
      await _load();
    }
  }

  Future<void> _togglePinned(TaskRecord task) async {
    if (!task.isCustom) return;
    await _repository.setPinned(task.id, !task.pinned);
    await _load();
  }

  Future<void> _resetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_text(context, en: 'Reset progress', ar: 'إعادة التقدم')),
        content: Text(
          _text(
            context,
            en: 'This will mark every task as pending again.',
            ar: 'سيتم إعادة كل المهام إلى حالة "قيد الانتظار".',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.send),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.resetProgress();
      await _load();
    }
  }

  List<TaskRecord> _filteredTasks(TaskDashboard dashboard) {
    final query = _query.trim().toLowerCase();
    return dashboard.tasks.where((task) {
      final matchesQuery =
          query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query) ||
          StudentGuideContent.categoryLabel(
            task.category,
            context,
          ).toLowerCase().contains(query) ||
          (task.notes ?? '').toLowerCase().contains(query);

      final matchesFilter = switch (_filter) {
        _TaskFilter.all => true,
        _TaskFilter.active => !task.isDone,
        _TaskFilter.completed => task.isDone,
        _TaskFilter.custom => task.isCustom,
        _TaskFilter.dueSoon => task.isDueSoon,
        _TaskFilter.overdue => task.isOverdue,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }

  GuideArticle? _articleForTask(Locale locale, TaskRecord task) {
    for (final article in StudentGuideContent.articles(locale)) {
      if (article.category == task.category) {
        return article;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final dashboard = _dashboard;
    final filteredTasks = dashboard == null
        ? const <TaskRecord>[]
        : _filteredTasks(dashboard);
    final nextTask = dashboard?.nextAction;
    final nextArticle = nextTask == null
        ? null
        : _articleForTask(locale, nextTask);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.settlementPlan),
        actions: [
          IconButton(
            tooltip: _text(context, en: 'Refresh', ar: 'تحديث'),
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                _resetProgress();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reset',
                child: Text(
                  _text(context, en: 'Reset progress', ar: 'إعادة التقدم'),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : () => _openTaskEditor(),
        icon: const Icon(Icons.add),
        label: Text(_text(context, en: 'Add task', ar: 'إضافة مهمة')),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading && dashboard == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                children: [
                  _DashboardHero(
                    progress: dashboard?.progress ?? 0,
                    totalCount: dashboard?.totalCount ?? 0,
                    completedCount: dashboard?.completedCount ?? 0,
                    pendingCount: dashboard?.pendingCount ?? 0,
                    inProgressCount: dashboard?.inProgressCount ?? 0,
                    customCount: dashboard?.customCount ?? 0,
                    dueSoonCount: dashboard?.dueSoonCount ?? 0,
                    overdueCount: dashboard?.overdueCount ?? 0,
                  ),
                  const SizedBox(height: 14),
                  if (nextTask != null) ...[
                    _NextActionCard(
                      task: nextTask,
                      article: nextArticle,
                      onOpenArticle: nextArticle == null
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    GuideDetailPage(article: nextArticle),
                              ),
                            ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  _SearchAndFilterBar(
                    controller: _searchController,
                    selectedFilter: _filter,
                    onFilterChanged: (filter) =>
                        setState(() => _filter = filter),
                    onClear: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
                  const SizedBox(height: 14),
                  if (dashboard != null) ...[
                    _OverviewMetrics(
                      totalCount: dashboard.totalCount,
                      completedCount: dashboard.completedCount,
                      dueSoonCount: dashboard.dueSoonCount,
                      customCount: dashboard.customCount,
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (filteredTasks.isEmpty)
                    _EmptyState(
                      title: _text(
                        context,
                        en: 'No tasks found',
                        ar: 'لا توجد مهام',
                      ),
                      subtitle: _text(
                        context,
                        en: 'Add a custom task or clear the filters to see more.',
                        ar: 'أضف مهمة مخصصة أو امسح عوامل التصفية لعرض المزيد.',
                      ),
                    )
                  else
                    for (final task in filteredTasks) ...[
                      _TaskCard(
                        task: task,
                        categoryLabel: StudentGuideContent.categoryLabel(
                          task.category,
                          context,
                        ),
                        dueDateText: task.dueDate == null
                            ? null
                            : DateFormat.yMMMd(
                                locale.toString(),
                              ).format(task.dueDate!),
                        onToggle: () => _toggleStatus(task),
                        onStatusChanged: (status) => _setStatus(task, status),
                        onOpenGuide: () {
                          final article = _articleForTask(locale, task);
                          if (article == null) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GuideDetailPage(article: article),
                            ),
                          );
                        },
                        onEdit: task.isCustom
                            ? () => _openTaskEditor(task: task)
                            : null,
                        onDelete: task.isCustom
                            ? () => _deleteCustomTask(task)
                            : null,
                        onTogglePinned: task.isCustom
                            ? () => _togglePinned(task)
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.progress,
    required this.totalCount,
    required this.completedCount,
    required this.pendingCount,
    required this.inProgressCount,
    required this.customCount,
    required this.dueSoonCount,
    required this.overdueCount,
  });

  final double progress;
  final int totalCount;
  final int completedCount;
  final int pendingCount;
  final int inProgressCount;
  final int customCount;
  final int dueSoonCount;
  final int overdueCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.track_changes, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _text(context, en: 'Task Center', ar: 'مركز المهام'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _text(
                        context,
                        en: 'Plan university paperwork, deadlines, and daily follow-up in one place.',
                        ar: 'نظم أوراق الجامعة والمواعيد والمتابعة اليومية في مكان واحد.',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            UiTexts.progressComplete(context, (progress * 100).round()),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroMetric(
                label: _text(context, en: 'Total', ar: 'الإجمالي'),
                value: '$totalCount',
              ),
              _HeroMetric(
                label: _text(context, en: 'Done', ar: 'منجز'),
                value: '$completedCount',
              ),
              _HeroMetric(
                label: _text(context, en: 'Pending', ar: 'قيد الانتظار'),
                value: '$pendingCount',
              ),
              _HeroMetric(
                label: _text(context, en: 'In progress', ar: 'قيد التنفيذ'),
                value: '$inProgressCount',
              ),
              _HeroMetric(
                label: _text(context, en: 'Custom', ar: 'مخصصة'),
                value: '$customCount',
              ),
              _HeroMetric(
                label: _text(context, en: 'Due soon', ar: 'قريبة الاستحقاق'),
                value: '$dueSoonCount',
              ),
              _HeroMetric(
                label: _text(context, en: 'Overdue', ar: 'متأخرة'),
                value: '$overdueCount',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 114,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextActionCard extends StatelessWidget {
  const _NextActionCard({
    required this.task,
    required this.article,
    required this.onOpenArticle,
  });

  final TaskRecord task;
  final GuideArticle? article;
  final VoidCallback? onOpenArticle;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _text(
                          context,
                          en: 'Recommended next step',
                          ar: 'الخطوة التالية المقترحة',
                        ),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(task.title),
                    ],
                  ),
                ),
              ],
            ),
            if (article != null) ...[
              const SizedBox(height: 12),
              Text(
                _text(
                  context,
                  en: 'Open the matching guide to finish it faster.',
                  ar: 'افتح الدليل المرتبط لإكمالها بسرعة أكبر.',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onOpenArticle,
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(AppLocalizations.of(context)!.suggestedNextStep),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({
    required this.controller,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final _TaskFilter selectedFilter;
  final ValueChanged<_TaskFilter> onFilterChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchBar(
          controller: controller,
          hintText: _text(
            context,
            en: 'Search tasks, notes, or categories',
            ar: 'ابحث في المهام أو الملاحظات أو التصنيفات',
          ),
          leading: const Icon(Icons.search),
          trailing: [
            if (controller.text.isNotEmpty)
              IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
          ],
          onChanged: (_) {},
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final filter in _TaskFilter.values) ...[
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: FilterChip(
                    label: Text(_filterLabel(context, filter)),
                    selected: selectedFilter == filter,
                    onSelected: (_) => onFilterChanged(filter),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _filterLabel(BuildContext context, _TaskFilter filter) {
    return switch (filter) {
      _TaskFilter.all => _text(context, en: 'All', ar: 'الكل'),
      _TaskFilter.active => _text(context, en: 'Active', ar: 'نشطة'),
      _TaskFilter.completed => _text(context, en: 'Completed', ar: 'منجزة'),
      _TaskFilter.custom => _text(context, en: 'Custom', ar: 'مخصصة'),
      _TaskFilter.dueSoon => _text(context, en: 'Due soon', ar: 'قريبة'),
      _TaskFilter.overdue => _text(context, en: 'Overdue', ar: 'متأخرة'),
    };
  }
}

class _OverviewMetrics extends StatelessWidget {
  const _OverviewMetrics({
    required this.totalCount,
    required this.completedCount,
    required this.dueSoonCount,
    required this.customCount,
  });

  final int totalCount;
  final int completedCount;
  final int dueSoonCount;
  final int customCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _MetricCard(
          icon: Icons.view_list_outlined,
          label: _text(context, en: 'Total tasks', ar: 'إجمالي المهام'),
          value: '$totalCount',
        ),
        _MetricCard(
          icon: Icons.check_circle_outline,
          label: _text(context, en: 'Completed', ar: 'منجزة'),
          value: '$completedCount',
        ),
        _MetricCard(
          icon: Icons.schedule_outlined,
          label: _text(context, en: 'Due soon', ar: 'قريبة'),
          value: '$dueSoonCount',
        ),
        _MetricCard(
          icon: Icons.edit_note_outlined,
          label: _text(context, en: 'Custom tasks', ar: 'مهام مخصصة'),
          value: '$customCount',
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 42) / 2,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.labelMedium),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.categoryLabel,
    required this.dueDateText,
    required this.onToggle,
    required this.onStatusChanged,
    required this.onOpenGuide,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePinned,
  });

  final TaskRecord task;
  final String categoryLabel;
  final String? dueDateText;
  final VoidCallback onToggle;
  final ValueChanged<TaskStatus> onStatusChanged;
  final VoidCallback onOpenGuide;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTogglePinned;

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel(context, task.status);
    final statusColor = _statusColor(context, task.status);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(value: task.isDone, onChanged: (_) => onToggle()),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(task.description),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'pending':
                        onStatusChanged(TaskStatus.pending);
                        break;
                      case 'progress':
                        onStatusChanged(TaskStatus.inProgress);
                        break;
                      case 'done':
                        onStatusChanged(TaskStatus.done);
                        break;
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                      case 'pin':
                        onTogglePinned?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'pending',
                      child: Text(
                        _text(context, en: 'Mark pending', ar: 'تعليق المهمة'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'progress',
                      child: Text(
                        _text(
                          context,
                          en: 'Mark in progress',
                          ar: 'قيد التنفيذ',
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'done',
                      child: Text(_text(context, en: 'Mark done', ar: 'منجزة')),
                    ),
                    if (task.isCustom) ...[
                      PopupMenuItem(
                        value: 'pin',
                        child: Text(
                          task.pinned
                              ? _text(context, en: 'Unpin', ar: 'إلغاء التثبيت')
                              : _text(context, en: 'Pin', ar: 'تثبيت'),
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(_text(context, en: 'Edit', ar: 'تعديل')),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(_text(context, en: 'Delete', ar: 'حذف')),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TaskChip(icon: Icons.category_outlined, label: categoryLabel),
                _TaskChip(
                  icon: Icons.flag_outlined,
                  label: _priorityLabel(context, task.priority),
                ),
                _TaskChip(
                  icon: statusColor == Colors.green
                      ? Icons.check_circle_outline
                      : Icons.timelapse_outlined,
                  label: statusLabel,
                  color: statusColor,
                ),
                if (dueDateText != null)
                  _TaskChip(
                    icon: task.isOverdue
                        ? Icons.warning_amber_outlined
                        : Icons.event_outlined,
                    label: dueDateText!,
                    color: task.isOverdue
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                if (task.pinned)
                  _TaskChip(
                    icon: Icons.push_pin_outlined,
                    label: _text(context, en: 'Pinned', ar: 'مثبتة'),
                  ),
                if (task.isCustom)
                  _TaskChip(
                    icon: Icons.edit_note_outlined,
                    label: _text(context, en: 'Custom', ar: 'مخصصة'),
                  ),
              ],
            ),
            if (task.notes != null && task.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(task.notes!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onOpenGuide,
                  icon: const Icon(Icons.menu_book_outlined),
                  label: Text(
                    _text(context, en: 'Open guide', ar: 'افتح الدليل'),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onToggle,
                  icon: Icon(task.isDone ? Icons.undo : Icons.check),
                  label: Text(
                    task.isDone
                        ? _text(context, en: 'Undo', ar: 'تراجع')
                        : _text(context, en: 'Complete', ar: 'إكمال'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _priorityLabel(BuildContext context, int priority) {
    if (priority <= 2) {
      return _text(context, en: 'Priority: high', ar: 'الأولوية: عالية');
    }
    if (priority <= 4) {
      return _text(context, en: 'Priority: medium', ar: 'الأولوية: متوسطة');
    }
    return _text(context, en: 'Priority: low', ar: 'الأولوية: منخفضة');
  }

  String _statusLabel(BuildContext context, TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => _text(context, en: 'Pending', ar: 'قيد الانتظار'),
      TaskStatus.inProgress => _text(
        context,
        en: 'In progress',
        ar: 'قيد التنفيذ',
      ),
      TaskStatus.done => _text(context, en: 'Done', ar: 'منجزة'),
    };
  }

  Color _statusColor(BuildContext context, TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => Theme.of(context).colorScheme.outline,
      TaskStatus.inProgress => Theme.of(context).colorScheme.tertiary,
      TaskStatus.done => Colors.green,
    };
  }
}

class _TaskChip extends StatelessWidget {
  const _TaskChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.checklist_rtl,
            size: 54,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _TaskEditorSheet extends StatefulWidget {
  const _TaskEditorSheet({this.initialTask});

  final TaskRecord? initialTask;

  @override
  State<_TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<_TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;

  late GuideCategory _category;
  late int _priority;
  late bool _pinned;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _notesController = TextEditingController(text: task?.notes ?? '');
    _category = task?.category ?? GuideCategory.afterArrival;
    _priority = task?.priority ?? 3;
    _pinned = task?.pinned ?? false;
    _dueDate = task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.initialTask;
    final now = DateTime.now();
    final task = TaskRecord(
      id: existing?.id ?? 'custom-${now.microsecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      priority: _priority,
      status: existing?.status ?? TaskStatus.pending,
      createdAt: existing?.createdAt ?? now,
      dueDate: _dueDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      pinned: _pinned,
      isCustom: true,
    );
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final locale = Localizations.localeOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initialTask == null
                    ? _text(
                        context,
                        en: 'Add custom task',
                        ar: 'إضافة مهمة مخصصة',
                      )
                    : _text(
                        context,
                        en: 'Edit custom task',
                        ar: 'تعديل مهمة مخصصة',
                      ),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _text(
                  context,
                  en: 'Capture deadlines, paperwork, and personal follow-up in one task list.',
                  ar: 'سجّل المواعيد والأوراق والمتابعة الشخصية في قائمة واحدة.',
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: _text(
                    context,
                    en: 'Task title',
                    ar: 'عنوان المهمة',
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return _text(
                      context,
                      en: 'Please enter a title.',
                      ar: 'يرجى إدخال عنوان.',
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: _text(context, en: 'Details', ar: 'التفاصيل'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return _text(
                      context,
                      en: 'Please add a short description.',
                      ar: 'أضف وصفًا قصيرًا من فضلك.',
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<GuideCategory>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: _text(context, en: 'Category', ar: 'التصنيف'),
                  border: const OutlineInputBorder(),
                ),
                items: GuideCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(
                          StudentGuideContent.categoryLabel(category, context),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              Text(
                _text(context, en: 'Priority', ar: 'الأولوية'),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              Slider(
                value: _priority.toDouble(),
                min: 1,
                max: 6,
                divisions: 5,
                label: '$_priority',
                onChanged: (value) => setState(() => _priority = value.round()),
              ),
              const SizedBox(height: 6),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _pinned,
                onChanged: (value) => setState(() => _pinned = value),
                title: Text(
                  _text(context, en: 'Pin to top', ar: 'تثبيت بالأعلى'),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(
                  _dueDate == null
                      ? _text(context, en: 'No due date', ar: 'لا يوجد موعد')
                      : DateFormat.yMMMd(locale.toString()).format(_dueDate!),
                ),
                subtitle: Text(
                  _text(context, en: 'Due date', ar: 'موعد الاستحقاق'),
                ),
                trailing: TextButton(
                  onPressed: _pickDueDate,
                  child: Text(_text(context, en: 'Choose', ar: 'اختيار')),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: _text(context, en: 'Notes', ar: 'ملاحظات'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: Text(
                        widget.initialTask == null
                            ? _text(context, en: 'Add task', ar: 'إضافة المهمة')
                            : _text(
                                context,
                                en: 'Save changes',
                                ar: 'حفظ التعديلات',
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _text(BuildContext context, {required String en, required String ar}) {
  return UiTexts.text(context, en: en, ar: ar);
}
