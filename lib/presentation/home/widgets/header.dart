import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/domain/auth/entity/user.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/presentation/meal_details/bloc/vegetarian_filter_cubit.dart';

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
              _menuIcon(context), 
              _userName(state.user),
              _vegetarianSwitch(context),
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

  Widget _menuIcon(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    );
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

Widget _vegetarianSwitch(BuildContext context) {
  return BlocBuilder<VegetarianFilterCubit, bool>(
    builder: (context, isVegetarian) {
      return Row(
        children: [
          Icon(Icons.eco, color: isVegetarian ? Colors.green : Colors.grey),
          const SizedBox(width: 8),
          Switch(
            value: isVegetarian,
            onChanged: (newValue) {
              context.read<VegetarianFilterCubit>().toggle();
            },
          ),
        ],
      );
    },
  );
}