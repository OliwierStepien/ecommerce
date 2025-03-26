import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/domain/auth/entity/user.dart';
import 'package:mealapp/domain/auth/usecases/signout.dart';
import 'package:mealapp/presentation/meal_details/pages/favorite_meals.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_state.dart';
import 'package:mealapp/presentation/shopping_list/pages/shopping_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserInfoDisplayCubit, UserInfoDisplayState>(
      builder: (context, state) {
        if (state is UserInfoLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is UserInfoLoaded) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // _shoppingList(context),
              // _favoriteIcon(context),
              _userName(state.user),
              _logoutIcon(context),
            ],
          );
        }

        if (state is LoadUserInfoFailure) {
          return ErrorMessage(
            message: state.message,
            onRetry: () {
              context.read<UserInfoDisplayCubit>().displayUserInfo();
            },
          );
        }
        return Container();
      },
    );
  }
}

Widget _userName(UserEntity user) {
  return Text(
    'Witaj ${user.firstName}',
    style: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    softWrap: true,
    textAlign: TextAlign.start,
  );
}

Widget _logoutIcon(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.exit_to_app),
    onPressed: () {
      context.read<ButtonStateCubit>().execute(usecase: SignoutUsecase());
    },
  );
}

// Widget _favoriteIcon(BuildContext context) {
//   return IconButton(
//     icon: const Icon(Icons.favorite),
//     onPressed: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const FavoriteMealsPage()),
//       );
//     },
//   );
// }

// Widget _shoppingList(BuildContext context) {
//   return IconButton(
//     icon: const Icon(Icons.shopping_cart),
//     onPressed: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const ShoppingListPage(),
//         ),
//       );
//     },
//   );
// }
