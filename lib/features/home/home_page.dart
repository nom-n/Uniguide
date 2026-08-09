import 'package:flutter/material.dart';

import 'package:uniguide/core/content/student_guide_content.dart';
import 'package:uniguide/features/tasks/task_repository.dart';
import 'package:uniguide/core/localization/ui_texts.dart';
import 'package:uniguide/features/assistant/smart_assistant_page.dart';
import 'package:uniguide/features/guides/guide_detail_page.dart';
import 'package:uniguide/features/guides/guides_page.dart';
import 'package:uniguide/features/tasks/tasks_page.dart';
import 'package:uniguide/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repository = TaskRepository.instance;
  Locale? _loadedLocale;
  Future<TaskDashboard>? _dashboardFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_loadedLocale?.languageCode != locale.languageCode ||
        _loadedLocale?.countryCode != locale.countryCode ||
        _dashboardFuture == null) {
      _loadedLocale = locale;
      _dashboardFuture = _repository.load(locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    return FutureBuilder<TaskDashboard>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        final dashboard = snapshot.data;
        final articles = StudentGuideContent.articles(locale);
        final places = StudentGuideContent.places(locale);
        final tasks = dashboard?.tasks ?? StudentGuideContent.tasks(locale)
            .map((task) => TaskRecord.fromBuiltIn(task))
            .toList();
        final completedIds = tasks
            .where((task) => task.isDone)
            .map((task) => task.id)
            .toSet();
        final nextArticle = StudentGuideContent.nextRecommendedArticle(
          locale: locale,
          completedTaskIds: completedIds,
        );
        final progress = dashboard?.progress ?? 0;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF4F7FB), Color(0xFFEAF3FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: [
                  _HeroHeader(
                    title: lang.appTitle,
                    welcomeText: lang.welcome,
                    subtitle: _text(
                      context,
                      en: 'Everything a student needs, from arrival steps to housing, banking, and campus life.',
                      ar: 'كل ما يحتاجه الطالب من خطوات الوصول إلى السكن والبنك والحياة الجامعية.',
                    ),
                    progress: progress,
                  ),
                  const SizedBox(height: 14),
                  _QuickStats(
                    articleCount: articles.length,
                    taskCount: dashboard?.totalCount ?? tasks.length,
                    placeCount: places.length,
                  ),
                  const SizedBox(height: 14),
                  _FeatureCard(
                    title: _text(
                      context,
                      en: 'Recommended next step',
                      ar: 'الخطوة التالية المقترحة',
                    ),
                    subtitle: nextArticle?.title ??
                        _text(context, en: 'No pending steps left.', ar: 'لا توجد خطوات معلقة.'),
                    icon: Icons.auto_awesome,
                    accent: const Color(0xFF0A84FF),
                    onTap: nextArticle == null
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GuideDetailPage(article: nextArticle),
                            ),
                          ),
                  ),
                  const SizedBox(height: 14),
                  _FeatureCard(
                    title: _text(
                      context,
                      en: 'Smart assistant',
                      ar: 'المساعد الذكي',
                    ),
                    subtitle: _text(
                      context,
                      en: 'Search the guide base and jump to the most relevant article.',
                      ar: 'ابحث داخل قاعدة الأدلة وانتقل لأقرب مقال مناسب.',
                    ),
                    icon: Icons.smart_toy_outlined,
                    accent: const Color(0xFF1B9C85),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SmartAssistantPage()),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionHeader(
                    title: lang.tasks,
                    actionLabel: _text(context, en: 'Open all', ar: 'عرض الكل'),
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TasksPage()),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...tasks.take(3).map(
                        (task) => _ListTileCard(
                          icon: Icons.check_circle_outline,
                          title: task.title,
                          subtitle: task.description,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const TasksPage()),
                          ),
                        ),
                      ),
                  const SizedBox(height: 14),
                  _SectionHeader(
                    title: lang.services,
                    actionLabel: _text(context, en: 'Browse guides', ar: 'تصفح الأدلة'),
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GuidesPage()),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ServiceGrid(
                    onHousing: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const GuidesPage(initialCategory: GuideCategory.housing),
                      ),
                    ),
                    onResidence: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const GuidesPage(initialCategory: GuideCategory.afterArrival),
                      ),
                    ),
                    onUniversity: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const GuidesPage(initialCategory: GuideCategory.universityLife),
                      ),
                    ),
                    onTransport: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const GuidesPage(initialCategory: GuideCategory.transport),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionHeader(
                    title: _text(context, en: 'Important places', ar: 'أماكن مهمة'),
                    actionLabel: _text(context, en: 'Maps guide', ar: 'دليل الخرائط'),
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GuidesPage(
                          initialCategory: GuideCategory.maps,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...places.take(3).map(
                        (place) => _PlaceCard(
                          name: place.name,
                          type: place.type,
                          city: place.city,
                          description: place.description,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GuidesPage(
                                initialCategory: GuideCategory.maps,
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.title,
    required this.welcomeText,
    required this.subtitle,
    required this.progress,
  });

  final String title;
  final String welcomeText;
  final String subtitle;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A84FF), Color(0xFF1F9CFF), Color(0xFF63C2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A84FF).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Image.asset('assets/images/app_logo.png'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      welcomeText,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.94),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({
    required this.articleCount,
    required this.taskCount,
    required this.placeCount,
  });

  final int articleCount;
  final int taskCount;
  final int placeCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _StatTile(
          label: _text(context, en: 'Guides', ar: 'الأدلة'),
          value: '$articleCount',
          icon: Icons.menu_book_outlined,
        ),
        _StatTile(
          label: _text(context, en: 'Tasks', ar: 'المهام'),
          value: '$taskCount',
          icon: Icons.checklist_outlined,
        ),
        _StatTile(
          label: _text(context, en: 'Places', ar: 'الأماكن'),
          value: '$placeCount',
          icon: Icons.place_outlined,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 42) / 3,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(icon),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _ListTileCard extends StatelessWidget {
  const _ListTileCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 0,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(icon),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({
    required this.onHousing,
    required this.onResidence,
    required this.onUniversity,
    required this.onTransport,
  });

  final VoidCallback onHousing;
  final VoidCallback onResidence;
  final VoidCallback onUniversity;
  final VoidCallback onTransport;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.15,
      children: [
        _ActionTile(
          icon: Icons.home_outlined,
          label: AppLocalizations.of(context)!.housing,
          onTap: onHousing,
        ),
        _ActionTile(
          icon: Icons.badge_outlined,
          label: AppLocalizations.of(context)!.residence,
          onTap: onResidence,
        ),
        _ActionTile(
          icon: Icons.school_outlined,
          label: AppLocalizations.of(context)!.university,
          onTap: onUniversity,
        ),
        _ActionTile(
          icon: Icons.directions_bus_outlined,
          label: AppLocalizations.of(context)!.transport,
          onTap: onTransport,
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.name,
    required this.type,
    required this.city,
    required this.description,
    required this.onTap,
  });

  final String name;
  final String type;
  final String city;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 0,
        child: ListTile(
          leading: const Icon(Icons.place_outlined),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('$type - $city\n$description'),
          isThreeLine: true,
          trailing: const Icon(Icons.open_in_new),
          onTap: onTap,
        ),
      ),
    );
  }
}

String _text(
  BuildContext context, {
  required String en,
  required String ar,
}) {
  return UiTexts.text(context, en: en, ar: ar);
}
