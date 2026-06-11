import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:uniguide/core/content/student_guide_content.dart';

class GuideDetailPage extends StatelessWidget {
  const GuideDetailPage({super.key, required this.article});

  final GuideArticle article;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _HeroCard(article: article),
          const SizedBox(height: 16),
          for (var index = 0; index < article.steps.length; index++)
            _StepCard(index: index + 1, step: article.steps[index]),
          if (article.category == GuideCategory.maps) ...[
            const SizedBox(height: 10),
            Text(
              locale.languageCode == 'ar' ? 'مواقع مقترحة' : 'Suggested places',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final place in StudentGuideContent.places(locale))
              _PlaceTile(place: place),
          ],
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.article});

  final GuideArticle article;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(article.icon, size: 42),
            const SizedBox(height: 12),
            Text(
              article.summary,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: article.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.index, required this.step});

  final int index;
  final GuideStep step;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 16, child: Text('$index')),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(step.details),
            if (step.requiredDocuments.isNotEmpty) ...[
              const SizedBox(height: 12),
              _BulletGroup(
                icon: Icons.description_outlined,
                title: Localizations.localeOf(context).languageCode == 'ar'
                    ? 'المستندات'
                    : 'Documents',
                values: step.requiredDocuments,
              ),
            ],
            if (step.warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              _BulletGroup(
                icon: Icons.warning_amber_rounded,
                title: Localizations.localeOf(context).languageCode == 'ar'
                    ? 'تنبيهات'
                    : 'Warnings',
                values: step.warnings,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BulletGroup extends StatelessWidget {
  const _BulletGroup({
    required this.icon,
    required this.title,
    required this.values,
  });

  final IconData icon;
  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          for (final value in values)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $value'),
            ),
        ],
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({required this.place});

  final ImportantPlace place;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: const Icon(Icons.place_outlined),
        title: Text(place.name),
        subtitle: Text('${place.type} • ${place.description}'),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => launchUrl(
          Uri.parse(place.url),
          mode: LaunchMode.externalApplication,
        ),
      ),
    );
  }
}
