import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uniguide/core/admin/admin_content_service.dart';
import 'package:uniguide/l10n/app_localizations.dart';

class AdminConsolePage extends StatefulWidget {
  const AdminConsolePage({super.key});

  @override
  State<AdminConsolePage> createState() => _AdminConsolePageState();
}

class _AdminConsolePageState extends State<AdminConsolePage> {
  final _adminKeyController = TextEditingController();
  final _service = AdminContentService.instance;
  Future<Map<String, dynamic>>? _snapshotFuture;
  String? _message;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  @override
  void dispose() {
    _adminKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('admin_api_key') ?? '';
    if (!mounted) return;
    setState(() {
      _adminKeyController.text = key;
      if (key.isNotEmpty) {
        _snapshotFuture = _service.fetchSnapshot(key);
      }
    });
  }

  Future<void> _saveKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_api_key', _adminKeyController.text.trim());
    if (!mounted) return;
    setState(() {
      _snapshotFuture = _service.fetchSnapshot(_adminKeyController.text.trim());
      _message = 'Admin key saved.';
    });
  }

  Future<void> _refresh() async {
    final key = _adminKeyController.text.trim();
    if (key.isEmpty) {
      setState(() => _message = 'Enter the admin key first.');
      return;
    }
    setState(() {
      _snapshotFuture = _service.fetchSnapshot(key);
    });
  }

  Future<bool> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
      await _refresh();
      return true;
    } catch (e) {
      setState(() => _message = e.toString());
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = _adminKeyController.text.trim();
    return Scaffold(
      appBar: AppBar(
        title: Text(_text(context, en: 'Admin console', ar: 'لوحة الإدارة')),
        actions: [
          IconButton(
            onPressed: _busy ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _adminKeyController,
                    decoration: InputDecoration(
                      labelText: _text(context, en: 'Admin key', ar: 'مفتاح الإدارة'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _busy ? null : _saveKey,
                          child: Text(_text(context, en: 'Save key', ar: 'حفظ المفتاح')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _busy ? null : _refresh,
                          child: Text(AppLocalizations.of(context)!.refresh),
                        ),
                      ),
                    ],
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Text(_message!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (key.isEmpty)
            _EmptyState(
              message: _text(
                context,
                en: 'Enter your admin key to load and manage content.',
                ar: 'أدخل مفتاح الإدارة لتحميل وإدارة المحتوى.',
              ),
            )
          else
            FutureBuilder<Map<String, dynamic>>(
              future: _snapshotFuture ?? _service.fetchSnapshot(key),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _EmptyState(
                    message: _text(
                      context,
                      en: 'Unable to load content. Check the admin key and backend URL.',
                      ar: 'تعذر تحميل المحتوى. تحقق من مفتاح الإدارة وعنوان الخادم.',
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ));
                }
                final data = snapshot.data!;
                final guides = (data['guides'] as List? ?? const []).cast<Map<String, dynamic>>();
                final tasks = (data['tasks'] as List? ?? const []).cast<Map<String, dynamic>>();
                final places = (data['places'] as List? ?? const []).cast<Map<String, dynamic>>();
                final campaigns = (data['campaigns'] as List? ?? const []).cast<Map<String, dynamic>>();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SummaryRow(
                      guides: guides.length,
                      tasks: tasks.length,
                      places: places.length,
                      campaigns: campaigns.length,
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: _text(context, en: 'Guides', ar: 'الأدلة'),
                      actionLabel: _text(context, en: 'Add guide', ar: 'إضافة دليل'),
                      onAction: () => _showGuideForm(key),
                      children: [
                        for (final guide in guides)
                          _AdminItemTile(
                            title: guide['title']?.toString() ?? '',
                            subtitle: '${guide['locale']} • ${guide['category']}',
                            onDelete: () => _run(() => _service.deleteItem(
                              key,
                              '/admin/guides/${guide['id']}',
                            )),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: _text(context, en: 'Tasks', ar: 'المهام'),
                      actionLabel: _text(context, en: 'Add task', ar: 'إضافة مهمة'),
                      onAction: () => _showTaskForm(key),
                      children: [
                        for (final task in tasks)
                          _AdminItemTile(
                            title: task['title']?.toString() ?? '',
                            subtitle: '${task['locale']} • ${task['category']}',
                            onDelete: () => _run(() => _service.deleteItem(
                              key,
                              '/admin/tasks/${task['id']}',
                            )),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: _text(context, en: 'Places', ar: 'الأماكن'),
                      actionLabel: _text(context, en: 'Add place', ar: 'إضافة مكان'),
                      onAction: () => _showPlaceForm(key),
                      children: [
                        for (final place in places)
                          _AdminItemTile(
                            title: place['name']?.toString() ?? '',
                            subtitle: '${place['locale']} • ${place['city']}',
                            onDelete: () => _run(() => _service.deleteItem(
                              key,
                              '/admin/places/${place['id']}',
                            )),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: _text(context, en: 'Notifications', ar: 'الإشعارات'),
                      actionLabel: _text(context, en: 'Add campaign', ar: 'إضافة حملة'),
                      onAction: () => _showCampaignForm(key),
                      children: [
                        for (final campaign in campaigns)
                          _AdminItemTile(
                            title: campaign['title']?.toString() ?? '',
                            subtitle: '${campaign['status']} • ${campaign['locale'] ?? 'all'}',
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: _busy ? null : () => _run(() => _service.sendCampaign(key, campaign['id'].toString())),
                                  child: Text(_text(context, en: 'Send', ar: 'إرسال')),
                                ),
                              ],
                            ),
                            onDelete: () => _run(() => _service.deleteItem(
                              key,
                              '/admin/notifications/${campaign['id']}',
                            )),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _showGuideForm(String key) async {
    final locale = TextEditingController(text: 'en');
    final category = TextEditingController(text: 'afterArrival');
    final iconCode = TextEditingController(text: '57544');
    final title = TextEditingController();
    final summary = TextEditingController();
    final tags = TextEditingController();
    final steps = TextEditingController(text: '[]');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _buildFormSheet(
        title: _text(context, en: 'Add guide', ar: 'إضافة دليل'),
        fields: [
          locale,
          category,
          iconCode,
          title,
          summary,
          tags,
          steps,
        ],
        labels: const [
          'Locale',
          'Category',
          'Icon code point',
          'Title',
          'Summary',
          'Tags csv',
          'Steps JSON',
        ],
        onSubmit: () => _run(() => _service.createGuide(
          key,
          {
            'locale': locale.text.trim(),
            'category': category.text.trim(),
            'iconCodePoint': int.tryParse(iconCode.text.trim()) ?? 57544,
            'title': title.text.trim(),
            'summary': summary.text.trim(),
            'tags': tags.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
            'steps': jsonDecode(steps.text.trim()) as List<dynamic>,
            'isActive': true,
            'sortOrder': 0,
          },
        )),
      ),
    );
    locale.dispose();
    category.dispose();
    iconCode.dispose();
    title.dispose();
    summary.dispose();
    tags.dispose();
    steps.dispose();
  }

  Future<void> _showTaskForm(String key) async {
    final locale = TextEditingController(text: 'en');
    final category = TextEditingController(text: 'afterArrival');
    final title = TextEditingController();
    final description = TextEditingController();
    final priority = TextEditingController(text: '3');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _buildFormSheet(
        title: _text(context, en: 'Add task', ar: 'إضافة مهمة'),
        fields: [locale, category, title, description, priority],
        labels: const ['Locale', 'Category', 'Title', 'Description', 'Priority'],
        onSubmit: () => _run(() => _service.createTask(
          key,
          {
            'locale': locale.text.trim(),
            'category': category.text.trim(),
            'title': title.text.trim(),
            'description': description.text.trim(),
            'priority': int.tryParse(priority.text.trim()) ?? 3,
            'isActive': true,
            'sortOrder': 0,
          },
        )),
      ),
    );
    locale.dispose();
    category.dispose();
    title.dispose();
    description.dispose();
    priority.dispose();
  }

  Future<void> _showPlaceForm(String key) async {
    final locale = TextEditingController(text: 'en');
    final name = TextEditingController();
    final type = TextEditingController();
    final city = TextEditingController();
    final description = TextEditingController();
    final url = TextEditingController(text: 'https://maps.google.com');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _buildFormSheet(
        title: _text(context, en: 'Add place', ar: 'إضافة مكان'),
        fields: [locale, name, type, city, description, url],
        labels: const ['Locale', 'Name', 'Type', 'City', 'Description', 'URL'],
        onSubmit: () => _run(() => _service.createPlace(
          key,
          {
            'locale': locale.text.trim(),
            'name': name.text.trim(),
            'type': type.text.trim(),
            'city': city.text.trim(),
            'description': description.text.trim(),
            'url': url.text.trim(),
            'isActive': true,
            'sortOrder': 0,
          },
        )),
      ),
    );
    locale.dispose();
    name.dispose();
    type.dispose();
    city.dispose();
    description.dispose();
    url.dispose();
  }

  Future<void> _showCampaignForm(String key) async {
    final locale = TextEditingController(text: '');
    final title = TextEditingController();
    final body = TextEditingController();
    final audience = TextEditingController(text: 'all');
    final sendAt = TextEditingController(text: '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _buildFormSheet(
        title: _text(context, en: 'Add campaign', ar: 'إضافة حملة'),
        fields: [locale, title, body, audience, sendAt],
        labels: const ['Locale', 'Title', 'Body', 'Audience', 'Send at ISO'],
        onSubmit: () => _run(() => _service.createCampaign(
          key,
          {
            'locale': locale.text.trim().isEmpty ? null : locale.text.trim(),
            'title': title.text.trim(),
            'body': body.text.trim(),
            'audience': audience.text.trim(),
            'status': 'draft',
            if (sendAt.text.trim().isNotEmpty) 'sendAt': sendAt.text.trim(),
          },
        )),
      ),
    );
    locale.dispose();
    title.dispose();
    body.dispose();
    audience.dispose();
    sendAt.dispose();
  }

  Widget _buildFormSheet({
    required String title,
    required List<TextEditingController> fields,
    required List<String> labels,
    required Future<bool> Function() onSubmit,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (var i = 0; i < fields.length; i++) ...[
              TextField(controller: fields[i], decoration: InputDecoration(labelText: labels[i])),
              const SizedBox(height: 10),
            ],
            FilledButton(
              onPressed: () async {
                final success = await onSubmit();
                if (success && mounted) Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.send),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.guides,
    required this.tasks,
    required this.places,
    required this.campaigns,
  });

  final int guides;
  final int tasks;
  final int places;
  final int campaigns;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _SummaryTile(label: 'Guides', value: '$guides'),
        _SummaryTile(label: 'Tasks', value: '$tasks'),
        _SummaryTile(label: 'Places', value: '$places'),
        _SummaryTile(label: 'Campaigns', value: '$campaigns'),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    required this.children,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
                TextButton(onPressed: onAction, child: Text(actionLabel)),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _AdminItemTile extends StatelessWidget {
  const _AdminItemTile({
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ??
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, textAlign: TextAlign.center),
    );
  }
}

String _text(
  BuildContext context, {
  required String en,
  required String ar,
}) {
  return Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
}
