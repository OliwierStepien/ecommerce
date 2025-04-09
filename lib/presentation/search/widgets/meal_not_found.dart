import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealapp/core/configs/assets/app_vectors.dart';

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
      const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Przepraszamy, nie znaleźliśmy żadnych pasujących wyników dla Twojego wyszukiwania.",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
      )
    ],
  );
  }
}