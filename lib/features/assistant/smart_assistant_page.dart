import 'package:flutter/material.dart';

import 'package:uniguide/core/content/student_guide_content.dart';
import 'package:uniguide/features/guides/guide_detail_page.dart';
import 'package:uniguide/l10n/app_localizations.dart';

class SmartAssistantPage extends StatefulWidget {
  const SmartAssistantPage({super.key});

  @override
  State<SmartAssistantPage> createState() => _SmartAssistantPageState();
}

class _SmartAssistantPageState extends State<SmartAssistantPage> {
  final _questionController = TextEditingController();
  List<GuideArticle> _matches = [];
  String? _activePrompt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _answer();
      }
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _answer() {
    final locale = Localizations.localeOf(context);
    final query = _questionController.text;
    final matches = StudentGuideContent.articles(
      locale,
    ).where((article) => article.matches(query)).toList();
    setState(() {
      _activePrompt = query.trim().isEmpty ? null : query.trim();
      _matches = matches.isEmpty
          ? StudentGuideContent.articles(locale).take(3).toList()
          : matches.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final lang = AppLocalizations.of(context)!;
    final suggestions = StudentGuideContent.tasks(locale).take(3).toList();
    final quickPrompts = <String>[
      _text(context, en: 'bank account', ar: 'حساب بنكي'),
      _text(context, en: 'residence permit', ar: 'الإقامة'),
      _text(context, en: 'housing', ar: 'السكن'),
      _text(context, en: 'transport card', ar: 'بطاقة المواصلات'),
      _text(context, en: 'university registration', ar: 'التسجيل الجامعي'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(lang.smartAssistantTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.smart_toy_outlined, size: 42),
                  const SizedBox(height: 12),
                  Text(
                    lang.smartAssistantIntro,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(lang.smartAssistantDescription),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: quickPrompts
                        .map(
                          (prompt) => ActionChip(
                            label: Text(prompt),
                            onPressed: () {
                              _questionController.text = prompt;
                              _answer();
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _questionController,
            minLines: 2,
            maxLines: 4,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _answer(),
            decoration: InputDecoration(
              labelText: lang.smartAssistantQuestionLabel,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: lang.searchTooltip,
                onPressed: _answer,
                icon: const Icon(Icons.send),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            lang.quickSuggestions,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions
                .map(
                  (task) => ActionChip(
                    label: Text(task.title),
                    onPressed: () {
                      _questionController.text = task.title;
                      _answer();
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          if (_activePrompt != null) ...[
            Text(
              _text(
                context,
                en: 'Suggested matches',
                ar: 'نتائج مقترحة',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _text(
                context,
                en: 'Search query: ',
                ar: 'عبارة البحث: ',
              ) +
                  _activePrompt!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
          ],
          if (_matches.isEmpty)
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _text(
                    context,
                    en: 'Try a different topic or choose one of the quick prompts above.',
                    ar: 'جرّب موضوعًا آخر أو اختر أحد الاقتراحات السريعة بالأعلى.',
                  ),
                ),
              ),
            )
          else
            for (final article in _matches)
              Card(
                elevation: 0,
                child: ListTile(
                  leading: CircleAvatar(child: Icon(article.icon)),
                  title: Text(article.title),
                  subtitle: Text(
                    '${StudentGuideContent.categoryLabel(article.category, context)}\n${article.summary}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GuideDetailPage(article: article),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

String _text(
  BuildContext context, {
  required String en,
  required String ar,
}) {
  final code = Localizations.localeOf(context).languageCode;
  return code == 'ar' ? ar : en;
}
