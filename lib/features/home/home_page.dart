import 'package:flutter/material.dart';
import 'package:uniguide/l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(lang.appTitle, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final welcomeSize =
                    (constraints.maxWidth * 0.055).clamp(18.0, 26.0);
                return Text(
                  lang.welcome,
                  style: TextStyle(
                    fontSize: welcomeSize,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            _buildNextStepCard(context),

            const SizedBox(height: 20),

            _buildTasksSection(context),

            const SizedBox(height: 20),

            _buildServicesGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNextStepCard(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.white, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              lang.nextStep,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.tasks,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        _TaskItem(title: lang.kimlik_randevu, done: true),
        _TaskItem(title: lang.hesap_acma, done: false),
        _TaskItem(title: lang.ogr_kart, done: false),
      ],
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final w = MediaQuery.sizeOf(context).width;
    final columns = w >= 900 ? 4 : (w >= 600 ? 3 : 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.services,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _ServiceCard(icon: Icons.home, title: lang.housing),
            _ServiceCard(icon: Icons.badge, title: lang.residence),
            _ServiceCard(icon: Icons.school, title: lang.university),
            _ServiceCard(icon: Icons.directions_bus, title: lang.transport),
          ],
        ),
      ],
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String title;
  final bool done;

  const _TaskItem({required this.title, required this.done});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: done ? Colors.green : Colors.grey,
      ),
      title: Text(title),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ServiceCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 5),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 35, color: Colors.blue),
          const SizedBox(height: 10),
          Text(title),
        ],
      ),
    );
  }
}
