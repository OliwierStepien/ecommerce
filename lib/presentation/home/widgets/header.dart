import 'package:go_router/go_router.dart';
import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/domain/auth/entity/user_entity.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/friends/bloc/friend_cubit.dart';
import 'package:mealapp/presentation/friends/bloc/friend_state.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/routes/routes.dart';

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
              const _MenuIcon(),
              _UserNameWithInvitations(user: state.user),
              const _CalendarIcon(),
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
        return const SizedBox.shrink();
      },
    );
  }
}

class _MenuIcon extends StatelessWidget {
  const _MenuIcon();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    );
  }
}

class _UserNameWithInvitations extends StatelessWidget {
  final UserEntity user;
  const _UserNameWithInvitations({required this.user});

  @override
  Widget build(BuildContext context) {
    // Automatyczne ładowanie liczby zaproszeń przy budowaniu widgetu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final friendsCubit = context.read<FriendsCubit>();
      if (friendsCubit.state is FriendsInitial) {
        friendsCubit.loadPendingInvitationsCount();
      }
    });

    return BlocBuilder<FriendsCubit, FriendsState>(
      builder: (context, friendsState) {
        final invitationsCount = friendsState.invitationsCount;

        return GestureDetector(
          onTap: () {
            context.push(Routes.nestedUserInfoPage);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.transparent,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tekst powitania
                Text(
                  context.l10n.helloUser(user.firstName),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  textAlign: TextAlign.start,
                ),

                // Badge z liczbą zaproszeń (jeśli są)
                if (invitationsCount > 0) ...[
                  const SizedBox(width: 8),
                  _InvitationsBadge(count: invitationsCount),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InvitationsBadge extends StatelessWidget {
  final int count;

  const _InvitationsBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CalendarIcon extends StatelessWidget {
  const _CalendarIcon();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.calendar_month_outlined),
      onPressed: () {
        context.push(Routes.nestedCalendarPage);
      },
    );
  }
}
