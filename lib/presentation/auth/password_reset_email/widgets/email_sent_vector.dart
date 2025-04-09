import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealapp/core/configs/assets/app_vectors.dart';

class EmailSending extends StatelessWidget {
  const EmailSending({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(AppVectors.emailSending),
    );
  }
}