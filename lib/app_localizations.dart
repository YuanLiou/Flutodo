import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
    AppLocalizations(this.locale);

    final Locale locale;
    Map<String, String> _localizedStrings;

    static AppLocalizations of(BuildContext context) {
        return Localizations.of<AppLocalizations>(context, AppLocalizations);
    }

    static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

    Future<bool> load() async {
        String jsonString = await rootBundle.loadString('lang/${locale.languageCode}_${locale.countryCode}.json');
        Map<String, dynamic> jsonMap = json.decode(jsonString);
        _localizedStrings = jsonMap.map((key, value) {
            return MapEntry(key, value.toString());
        });

        return true;
    }

    String translate(String key) {
        return _localizedStrings[key];
    }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
    const _AppLocalizationsDelegate();

    @override
    bool isSupported(Locale locale) {
        return ['en', 'zh'].contains(locale.languageCode);
    }

    @override
    Future<AppLocalizations> load(Locale locale) async{
        AppLocalizations appLocalizations = new AppLocalizations(locale);
        await appLocalizations.load();
        return appLocalizations;
    }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}