import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uniguide/core/content/student_guide_content.dart';

Map<String, dynamic> _serializeGuide(GuideArticle article, String locale) {
  return {
    'locale': locale,
    'category': article.category.name,
    'iconCodePoint': article.icon.codePoint,
    'iconFontFamily': article.icon.fontFamily,
    'iconFontPackage': article.icon.fontPackage,
    'title': article.title,
    'summary': article.summary,
    'tags': article.tags,
    'steps': article.steps
        .map(
          (step) => {
            'title': step.title,
            'details': step.details,
            'requiredDocuments': step.requiredDocuments,
            'warnings': step.warnings,
            'links': step.links
                .map(
                  (link) => {
                    'label': link.label,
                    'url': link.url,
                  },
                )
                .toList(),
          },
        )
        .toList(),
    'isActive': true,
    'sortOrder': 0,
  };
}

Map<String, dynamic> _serializeTask(StudentTask task, String locale) {
  return {
    'locale': locale,
    'category': task.category.name,
    'title': task.title,
    'description': task.description,
    'priority': task.priority,
    'isActive': true,
    'sortOrder': task.priority,
  };
}

Map<String, dynamic> _serializePlace(ImportantPlace place, String locale) {
  return {
    'locale': locale,
    'name': place.name,
    'type': place.type,
    'city': place.city,
    'description': place.description,
    'url': place.url,
    'isActive': true,
    'sortOrder': 0,
  };
}

Future<void> main(List<String> args) async {
  const locales = ['en', 'ar', 'tr', 'fr', 'id', 'kk', 'so', 'ur'];
  final guides = <Map<String, dynamic>>[];
  final tasks = <Map<String, dynamic>>[];
  final places = <Map<String, dynamic>>[];

  for (final locale in locales) {
    final currentLocale = Locale(locale);
    for (final guide in StudentGuideContent.articles(currentLocale)) {
      guides.add(_serializeGuide(guide, locale));
    }
    for (final task in StudentGuideContent.tasks(currentLocale)) {
      tasks.add(_serializeTask(task, locale));
    }
    for (final place in StudentGuideContent.places(currentLocale)) {
      places.add(_serializePlace(place, locale));
    }
  }

  final output = <String, dynamic>{
    'guides': guides,
    'tasks': tasks,
    'places': places,
  };

  stdout.write(const JsonEncoder.withIndent('  ').convert(output));
}
