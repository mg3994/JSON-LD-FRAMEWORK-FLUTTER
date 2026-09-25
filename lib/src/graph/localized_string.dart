import 'package:flutter/material.dart';

/// Resolved localized string with fallback, direction (LTR/RTL), and pluralization support.
class LocalizedString {
  final Map<String, String> values; // e.g. {'en': 'Apple', 'fr': 'Pomme', 'default': 'Apple'}
  final String? direction; // 'ltr' or 'rtl'

  LocalizedString(this.values, {this.direction});

  factory LocalizedString.from(dynamic raw) {
    if (raw == null) return LocalizedString({});

    if (raw is String) {
      return LocalizedString({'default': raw});
    }

    if (raw is Map) {
      // Check standard JSON-LD language object: {"@value": "Apple", "@language": "en", "@direction": "ltr"}
      if (raw.containsKey('@value')) {
        final val = raw['@value'].toString();
        final lang = raw['@language']?.toString() ?? 'default';
        final dir = raw['@direction']?.toString();
        return LocalizedString({lang: val}, direction: dir);
      }

      final Map<String, String> map = {};
      raw.forEach((k, v) {
        if (v != null) map[k.toString()] = v.toString();
      });
      return LocalizedString(map);
    }

    if (raw is List) {
      final Map<String, String> map = {};
      String? foundDir;
      for (final item in raw) {
        if (item is Map && item.containsKey('@value')) {
          final val = item['@value'].toString();
          final lang = item['@language']?.toString() ?? 'default';
          if (item.containsKey('@direction')) {
            foundDir = item['@direction'].toString();
          }
          map[lang] = val;
        } else if (item is String) {
          map['default'] = item;
        }
      }
      return LocalizedString(map, direction: foundDir);
    }

    return LocalizedString({'default': raw.toString()});
  }

  TextDirection? get textDirection {
    if (direction == 'rtl') return TextDirection.rtl;
    if (direction == 'ltr') return TextDirection.ltr;
    return null;
  }

  /// Resolves the string value matching the provided Flutter [locale].
  String resolve(Locale? locale, {String? defaultLanguage = 'en', int? count}) {
    if (values.isEmpty) return '';

    if (locale != null) {
      final fullTag = locale.toLanguageTag().toLowerCase();
      final langCode = locale.languageCode.toLowerCase();

      if (values.containsKey(fullTag)) {
        return _applyPlural(values[fullTag]!, count);
      }
      if (values.containsKey(langCode)) {
        return _applyPlural(values[langCode]!, count);
      }
    }

    if (defaultLanguage != null && values.containsKey(defaultLanguage)) {
      return _applyPlural(values[defaultLanguage]!, count);
    }

    if (values.containsKey('default')) {
      return _applyPlural(values['default']!, count);
    }

    return _applyPlural(values.values.first, count);
  }

  String _applyPlural(String template, int? count) {
    if (count == null) return template;
    return template.replaceAll('{count}', count.toString()).replaceAll('{n}', count.toString());
  }

  @override
  String toString() => values.isNotEmpty ? values.values.first : '';
}
