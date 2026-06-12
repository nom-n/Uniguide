import 'package:flutter/material.dart';

import 'package:uniguide/core/content/student_guide_content.dart';
import 'package:uniguide/features/guides/guide_detail_page.dart';
import 'package:uniguide/l10n/app_localizations.dart';

class GuidesPage extends StatefulWidget {
  const GuidesPage({super.key, this.initialCategory});

  final GuideCategory? initialCategory;

  @override
  State<GuidesPage> createState() => _GuidesPageState();
}

class _GuidesPageState extends State<GuidesPage> {
  final _searchController = TextEditingController();
  GuideCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final articles = StudentGuideContent.articles(locale).where((article) {
      final categoryMatches =
          _selectedCategory == null || article.category == _selectedCategory;
      return categoryMatches && article.matches(_searchController.text);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(lang.studentGuideTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Semantics(
            textField: true,
            label: lang.searchGuideLabel,
            child: SearchBar(
              controller: _searchController,
              hintText: lang.searchGuideHint,
              leading: const Icon(Icons.search),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 14),
          _CategoryFilter(
            selected: _selectedCategory,
            onChanged: (category) =>
                setState(() => _selectedCategory = category),
          ),
          const SizedBox(height: 14),
          if (articles.isEmpty)
            _EmptyState(message: lang.noMatchingResults)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 3
                    : constraints.maxWidth >= 620
                    ? 2
                    : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: articles.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 178,
                  ),
                  itemBuilder: (context, index) => _GuideCard(
                    article: articles[index],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            GuideDetailPage(article: articles[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.selected, required this.onChanged});

  final GuideCategory? selected;
  final ValueChanged<GuideCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: FilterChip(
              label: Text(AppLocalizations.of(context)!.all),
              selected: selected == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          for (final category in GuideCategory.values)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: FilterChip(
                label: Text(
                  StudentGuideContent.categoryLabel(category, context),
                ),
                selected: selected == category,
                onSelected: (_) => onChanged(category),
              ),
            ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.article, required this.onTap});

  final GuideArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(child: Icon(article.icon)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      StudentGuideContent.categoryLabel(
                        article.category,
                        context,
                      ),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  article.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}
