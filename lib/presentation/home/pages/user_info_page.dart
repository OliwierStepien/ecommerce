// presentation/user_info/pages/user_info_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/common/helper/debug_log/debug_log.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/domain/auth/entity/user_entity.dart';
import 'package:mealapp/domain/friends/entity/friend_entity.dart';
import 'package:mealapp/domain/friends/entity/friend_invitation_entity.dart';
import 'package:mealapp/presentation/friends/bloc/friend_cubit.dart';
import 'package:mealapp/presentation/friends/bloc/friend_state.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_state.dart';
import 'package:mealapp/presentation/planned_meal_share/bloc/meal_share_cubit.dart';
import 'package:mealapp/presentation/planned_meal_share/bloc/meal_share_state.dart';
import 'package:mealapp/presentation/shopping_list_share/shopping_list_share_cubit.dart';
import 'package:mealapp/presentation/shopping_list_share/shopping_list_share_state.dart';

// ✅ freezer share
import 'package:mealapp/presentation/freezer_share/bloc/freezer_share_cubit.dart';
import 'package:mealapp/presentation/freezer_share/bloc/freezer_share_state.dart';

// ✅ NEW: po udostępnieniu odpal sync (żeby druga strona po pullu miała aktualne dane)
import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/service_locator.dart';

class UserInfoPage extends StatelessWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Twój profil',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<FriendsCubit, FriendsState>(
            listener: (context, state) {
              if (state is FriendsInitial) {
                debugLog('UserInfoPage: Automatyczne ładowanie zaproszeń');
                final friends = context.read<FriendsCubit>();
                friends.loadPendingInvitations();
                friends.loadPendingInvitationsCount();
                friends.loadFriends();
              }
            },
          ),
          BlocListener<UserInfoDisplayCubit, UserInfoDisplayState>(
            listener: (context, state) {
              if (state is UserInfoLoaded) {
                debugLog(
                    'UserInfoPage: Użytkownik zalogowany - ładowanie znajomych');
                if (context.read<FriendsCubit>().state is FriendsInitial) {
                  final friends = context.read<FriendsCubit>();
                  friends.loadPendingInvitations();
                  friends.loadPendingInvitationsCount();
                  friends.loadFriends();
                }
              }
            },
          ),

          // ⬇️ SnackBary po udostępnianiu posiłków
          BlocListener<MealShareCubit, MealShareState>(
            listenWhen: (prev, curr) =>
                curr is MealShareSuccess || curr is MealShareFailure,
            listener: (context, state) {
              if (state is MealShareSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is MealShareFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),

          // ⬇️ SnackBary po udostępnianiu listy zakupów
          BlocListener<ShoppingListShareCubit, ShoppingListShareState>(
            listenWhen: (prev, curr) =>
                curr is ShoppingListShareSuccess ||
                curr is ShoppingListShareFailure,
            listener: (context, state) {
              if (state is ShoppingListShareSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is ShoppingListShareFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),

          // ✅ SnackBary po udostępnianiu zamrażarki + sync po sukcesie
          BlocListener<FreezerShareCubit, FreezerShareState>(
            listenWhen: (prev, curr) =>
                curr is FreezerShareSuccess || curr is FreezerShareFailure,
            listener: (context, state) async {
              if (state is FreezerShareSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );

                // ✅ WAŻNE: odpalamy sync, żeby:
                // - dopchnąć ewentualne lokalne zmiany (jeśli masz kolejkę),
                // - a przede wszystkim "pociągnąć" świeże dane (pull) w miejscach,
                //   gdzie sync jest jedynym mechanizmem odświeżenia.
                await sl<SyncStrategy>().onDataChanged();
              } else if (state is FreezerShareFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<UserInfoDisplayCubit, UserInfoDisplayState>(
          builder: (context, state) {
            if (state is UserInfoLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UserInfoLoaded) {
              return _UserInfoContent(user: state.user);
            }

            if (state is LoadUserInfoFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Błąd ładowania danych',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UserInfoDisplayCubit>().displayUserInfo();
                      },
                      child: const Text('Spróbuj ponownie'),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _UserInfoContent extends StatelessWidget {
  final UserEntity user;

  const _UserInfoContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _UserInfoSection(user: user),
          const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.ink,
            labelStyle: TextStyle(fontWeight: FontWeight.w700),
            unselectedLabelColor: AppColors.muted,
            dividerColor: AppColors.hairline,
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Znajomi'),
              Tab(icon: Icon(Icons.person_add), text: 'Zaproszenia'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                const _FriendsTab(),
                _InvitationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  final UserEntity user;
  const _UserInfoSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hairline),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.background,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.firstName,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(color: AppColors.muted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendsTab extends StatelessWidget {
  const _FriendsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsCubit, FriendsState>(
      builder: (context, state) {
        if (state is FriendsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FriendsError) {
          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.danger, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<FriendsCubit>().loadFriends(),
                      child: const Text('Spróbuj ponownie'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is FriendsLoaded) {
          final addFriendCard = Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: CustomPaint(
              painter: const _DashedBorderPainter(
                color: AppColors.accent,
                radius: 8,
              ),
              child: ListTile(
                leading: const Icon(Icons.person_add, color: AppColors.accent),
                title: const Text(
                  'Dodaj znajomego',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.accent,
                ),
                onTap: () => _showAddFriendDialog(context),
              ),
            ),
          );

          if (state.friends.isEmpty) {
            return Column(
              children: [
                addFriendCard,
                const SizedBox(height: 32),
                const Expanded(child: _EmptyFriendsView()),
              ],
            );
          }

          return Column(
            children: [
              addFriendCard,
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.friends.length,
                  itemBuilder: (context, index) {
                    final friend = state.friends[index];
                    return _FriendListItem(
                      friend: friend,
                      onRemove: () => _showRemoveFriendDialog(context, friend),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _showAddFriendDialog(BuildContext context) async {
    String email = '';

    final String? result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Dodaj znajomego'),
          content: TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'email@przyklad.pl',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onChanged: (v) => email = v.trim(),
            onSubmitted: (_) {
              if (email.isNotEmpty) {
                Navigator.of(dialogContext).pop(email);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () {
                if (email.isNotEmpty) {
                  Navigator.of(dialogContext).pop(email);
                }
              },
              child: const Text('Wyślij zaproszenie'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      if (!context.mounted) return;
      context.read<FriendsCubit>().sendFriendInvitation(result);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Zaproszenie wysłane do $result'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showRemoveFriendDialog(
      BuildContext context, FriendEntity friend) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Usuń znajomego'),
        content: Text('Czy chcesz usunąć ${friend.friendName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Usuń', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      context.read<FriendsCubit>().removeFriend(friend.friendEmail);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usunięto ${friend.friendName} z listy znajomych'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _FriendListItem extends StatelessWidget {
  final FriendEntity friend;
  final VoidCallback onRemove;
  const _FriendListItem({required this.friend, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final mealShare = context.read<MealShareCubit>();
    final isSharing = context.watch<MealShareCubit>().state is MealShareLoading;

    final shoppingShare = context.read<ShoppingListShareCubit>();
    final isShoppingSharing =
        context.watch<ShoppingListShareCubit>().state
            is ShoppingListShareLoading;

    final freezerShare = context.read<FreezerShareCubit>();
    final isFreezerSharing =
        context.watch<FreezerShareCubit>().state is FreezerShareLoading;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hairline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.softFill,
          child: Text(
            friend.friendName.isNotEmpty
                ? friend.friendName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          friend.friendName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        subtitle: Text(
          friend.friendEmail,
          style: const TextStyle(color: AppColors.muted),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Udostępnij planned meals',
              icon: isSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.calendar_month, color: AppColors.muted),
              onPressed: isSharing
                  ? null
                  : () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.utc(2024, 1, 1),
                        lastDate: DateTime.utc(2035, 12, 31),
                        helpText: 'Wybierz zakres do udostępnienia',
                      );
                      if (picked == null) return;

                      final start = DateTime(
                        picked.start.year,
                        picked.start.month,
                        picked.start.day,
                      );
                      final end = DateTime(
                        picked.end.year,
                        picked.end.month,
                        picked.end.day,
                      );

                      mealShare.shareMeals(
                        friendUid: friend.friendUid,
                        start: start,
                        end: end,
                      );
                    },
            ),
            IconButton(
              tooltip: 'Udostępnij listę zakupów',
              icon: isShoppingSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.shopping_cart, color: AppColors.muted),
              onPressed: isShoppingSharing
                  ? null
                  : () {
                      shoppingShare.shareShoppingList(
                        friendUid: friend.friendUid,
                      );
                    },
            ),
            IconButton(
              tooltip: 'Udostępnij zamrażarkę',
              icon: isFreezerSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ac_unit, color: AppColors.muted),
              onPressed: isFreezerSharing
                  ? null
                  : () {
                      freezerShare.shareFreezer(
                        friendUid: friend.friendUid,
                      );
                    },
            ),
            IconButton(
              icon: const Icon(Icons.person_remove, color: AppColors.danger),
              tooltip: 'Usuń znajomego',
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<FriendsCubit, FriendsState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildInvitationsList(context, state),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInvitationsList(BuildContext context, FriendsState state) {
    final pendingInvitations = state.pendingInvitations;

    if (state is FriendsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pendingInvitations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_disabled,
                size: 64, color: Color(0xFFC6B8A2)),
            SizedBox(height: 16),
            Text('Brak oczekujących zaproszeń',
                style: TextStyle(fontSize: 18, color: AppColors.muted)),
            SizedBox(height: 8),
            Text('Zaproszenia od innych użytkowników\npojawiają się tutaj',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: pendingInvitations.length,
      itemBuilder: (context, index) {
        final invitation = pendingInvitations[index];
        return _InvitationListItem(
          invitation: invitation,
          onAccept: () => _showAcceptInvitationDialog(context, invitation),
          onReject: () => _showRejectInvitationDialog(context, invitation),
        );
      },
    );
  }

  void _showAcceptInvitationDialog(
      BuildContext context, FriendInvitationEntity invitation) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Zaakceptuj zaproszenie'),
        content: Text(
            'Czy chcesz zaakceptować zaproszenie od ${invitation.fromUserName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.herb),
            onPressed: () {
              dialogContext
                  .read<FriendsCubit>()
                  .respondToInvitation(invitation.id, true);
              Navigator.of(dialogContext).pop();
            },
            child:
                const Text('Zaakceptuj', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRejectInvitationDialog(
      BuildContext context, FriendInvitationEntity invitation) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Odrzuć zaproszenie'),
        content: Text(
            'Czy na pewno chcesz odrzucić zaproszenie od ${invitation.fromUserName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              dialogContext
                  .read<FriendsCubit>()
                  .respondToInvitation(invitation.id, false);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Odrzuć', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _InvitationListItem extends StatelessWidget {
  final FriendInvitationEntity invitation;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _InvitationListItem({
    required this.invitation,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hairline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              backgroundColor: AppColors.softFill,
              child: Text(
                invitation.fromUserName.isNotEmpty
                    ? invitation.fromUserName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invitation.fromUserName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    invitation.fromUserEmail,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Text(
            'Wysłano: ${_formatDate(invitation.sentAt)}',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Zaakceptuj'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.herb,
                  side: const BorderSide(color: AppColors.herb),
                ),
                onPressed: onAccept,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Odrzuć'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
                onPressed: onReject,
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _EmptyFriendsView extends StatelessWidget {
  const _EmptyFriendsView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 64, color: Color(0xFFC6B8A2)),
              SizedBox(height: 16),
              Text(
                'Brak znajomych',
                style: TextStyle(color: AppColors.muted, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text('Dodaj pierwszego znajomego!',
                  style: TextStyle(color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Przerywane obramowanie wiersza „Dodaj znajomego".
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dashWidth = 5.0;
    const dashGap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}