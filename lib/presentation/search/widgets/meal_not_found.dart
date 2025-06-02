import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealapp/core/configs/assets/app_vectors.dart';
import 'package:mealapp/extensions/context_extension.dart';

class MealNotFound extends StatelessWidget {
  const MealNotFound({super.key});

  @override
  Widget build(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SvgPicture.asset(
        AppVectors.notFound,
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          context.l10n.sorryWeCouldNotFindAnyMatchingResultsForYourSearch,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
      )
    ],
  );
  }
}