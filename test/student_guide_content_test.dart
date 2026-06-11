import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniguide/core/content/student_guide_content.dart';

void main() {
  test('guide content covers all required categories in Arabic', () {
    final articles = StudentGuideContent.articles(const Locale('ar'));
    final categories = articles.map((article) => article.category).toSet();

    expect(categories, containsAll(GuideCategory.values));
    expect(articles.every((article) => article.steps.isNotEmpty), isTrue);
  });

  test('local search finds banking content', () {
    final articles = StudentGuideContent.articles(const Locale('en'));
    final matches = articles
        .where((article) => article.matches('bank'))
        .toList();

    expect(matches, isNotEmpty);
    expect(
      matches.map((article) => article.category),
      contains(GuideCategory.banking),
    );
  });

  test('next recommendation follows pending task priority', () {
    final article = StudentGuideContent.nextRecommendedArticle(
      locale: const Locale('en'),
      completedTaskIds: const {},
    );

    expect(article, isNotNull);
    expect(article!.category, GuideCategory.afterArrival);
  });
}
