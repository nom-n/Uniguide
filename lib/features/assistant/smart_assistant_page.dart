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
          if (_matches.isNotEmpty)
            Text(
              lang.suggestedAnswers,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          for (final article in _matches)
            Card(
              elevation: 0,
              child: ListTile(
                leading: Icon(article.icon),
                title: Text(article.title),
                subtitle: Text(article.summary),
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
