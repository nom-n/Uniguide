import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uniguide/core/content/student_guide_content.dart';
import 'package:uniguide/features/guides/guide_detail_page.dart';
import 'package:uniguide/l10n/app_localizations.dart';

const _completedTaskIdsKey = 'completed_task_ids';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  Set<String> _completedIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _completedIds = prefs.getStringList(_completedTaskIdsKey)?.toSet() ?? {};
    });
  }

  Future<void> _toggle(String id) async {
    final next = Set<String>.from(_completedIds);
    next.contains(id) ? next.remove(id) : next.add(id);
    setState(() => _completedIds = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedTaskIdsKey, next.toList()..sort());
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final tasks = StudentGuideContent.tasks(locale);
    final progress = tasks.isEmpty ? 0.0 : _completedIds.length / tasks.length;
    final nextArticle = StudentGuideContent.nextRecommendedArticle(
      locale: locale,
      completedTaskIds: _completedIds,
    );

    return Scaffold(
      appBar: AppBar(title: Text(lang.settlementPlan)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.yourProgress,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 8),
                  Text(lang.completedSteps(_completedIds.length, tasks.length)),
                ],
              ),
            ),
          ),
          if (nextArticle != null) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              child: ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: Text(lang.suggestedNextStep),
                subtitle: Text(nextArticle.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GuideDetailPage(article: nextArticle),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          for (final task in tasks)
            Card(
              elevation: 0,
              child: CheckboxListTile(
                value: _completedIds.contains(task.id),
                onChanged: (_) => _toggle(task.id),
                secondary: CircleAvatar(child: Text('${task.priority}')),
                title: Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(task.description),
              ),
            ),
        ],
      ),
    );
  }
}
