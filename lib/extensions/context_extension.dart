
import 'package:flutter/material.dart';
import 'package:mealapp/l10n/app_localizations.dart';

extension BuildContextExtension on BuildContext{
AppLocalizations get l10n => AppLocalizations.of(this)!;
}