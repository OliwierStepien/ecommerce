import 'package:go_router/go_router.dart';
import 'package:mealapp/core/configs/assets/app_vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealapp/routes/routes.dart';

class SearchFieldHome extends StatelessWidget {
  const SearchFieldHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
       padding: const EdgeInsets.symmetric(
         horizontal: 16
       ),
      child: TextField(
        readOnly: true,
        onTap: (){
          context.push(Routes.nestedSearchPage);
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(12),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50)
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50)
          ),
          prefixIcon: SvgPicture.asset(
            AppVectors.search,
            fit: BoxFit.none,
          ),
          hintText: 'Szukaj',
          hintStyle: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
