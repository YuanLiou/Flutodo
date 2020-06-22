import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_todo/home_page.dart';
import 'app_localizations.dart';

void main() => runApp(TodoApp());

class TodoApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutodo',
      supportedLocales: [
        Locale('en', 'US'),
        Locale('zh', 'TW'),
        Locale.fromSubtags(languageCode: 'zh'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW')
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return supportedLocales.first;
        }

        for (var supportLocale in supportedLocales) {
          if (supportLocale.languageCode == locale.languageCode &&
                  supportLocale.countryCode == locale.countryCode) {
            return supportLocale;
          }
        }
        // fallback to first supported language
        return supportedLocales.first;
      },
      home: TodoList()
    );
  }
}