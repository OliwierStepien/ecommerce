// presentation/user_info/pages/user_info_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/common/helper/debug_log/debug_log.dart';
import 'package:mealapp/domain/auth/entity/user_entity.dart';
import 'package:mealapp/domain/friends/entity/friend_entity.dart';
import 'package:mealapp/domain/friends/entity/friend_invitation_entity.dart';
import 'package:mealapp/presentation/friends/bloc/friend_cubit.dart';
import 'package:mealapp/presentation/friends/bloc/friend_state.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_state.dart';

class UserInfoPage extends StatelessWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informacje użytkownika'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          // Listener dla automatycznego ładowania danych przy inicjalizacji
          BlocListener<FriendsCubit, FriendsState>(
            listener: (context, state) {
              if (state is FriendsInitial) {
                debugLog('UserInfoPage: Automatyczne ładowanie zaproszeń');
                context.read<FriendsCubit>().loadPendingInvitations();
                context.read<FriendsCubit>().loadPendingInvitationsCount();
                context
                    .read<FriendsCubit>()
                    .loadFriends(); // Dodaj też ładowanie znajomych
              }
            },
          ),
          // Listener dla aktualizacji po zalogowaniu
          BlocListener<UserInfoDisplayCubit, UserInfoDisplayState>(
            listener: (context, state) {
              if (state is UserInfoLoaded) {
                debugLog(
                    'UserInfoPage: Użytkownik zalogowany - ładowanie danych znajomych');
                // Upewnij się, że FriendsCubit jest zainicjalizowany
                if (context.read<FriendsCubit>().state is FriendsInitial) {
                  context.read<FriendsCubit>().loadPendingInvitations();
                  context.read<FriendsCubit>().loadPendingInvitationsCount();
                  context.read<FriendsCubit>().loadFriends();
                }
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
          // Sekcja danych użytkownika
          _UserInfoSection(user: user),

          // Zakładki
          Material(
            color: Theme.of(context).cardColor,
            child: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.people), text: 'Znajomi'),
                Tab(
                  icon: Icon(Icons.person_add),
                  text: 'Zaproszenia',
                ),
              ],
            ),
          ),

          // Zawartość zakładek
          Expanded(
            child: TabBarView(
              children: [
                _FriendsTab(),
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
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dane osobowe',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Imię',
              value: user.firstName,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Email',
              value: user.email,
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsCubit, FriendsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildContent(context, state),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, FriendsState state) {
    if (state is FriendsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is FriendsError) {
      return SingleChildScrollView(
        // DODANE - pozwala na scrollowanie
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<FriendsCubit>().loadFriends();
                  },
                  child: const Text('Spróbuj ponownie'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state is FriendsLoaded) {
      if (state.friends.isEmpty) {
        return Column(
          children: [
            // Przycisk dodaj znajomego - STAŁA WYSOKOŚĆ
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_add, color: Colors.blue),
                title: const Text('Dodaj znajomego'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showAddFriendDialog(context);
                },
              ),
            ),
            const SizedBox(height: 32),
            // Komunikat o braku znajomych - ROZSZERZALNY
            const Expanded(
              // DODANE - pozwala na zajęcie dostępnej przestrzeni
              child: Center(
                child: SingleChildScrollView(
                  // DODANE - bezpieczeństwo na małych ekranach
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Brak znajomych',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Dodaj pierwszego znajomego!',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }

      // Lista ze znajomymi
      return Column(
        children: [
          // Przycisk dodaj znajomego - STAŁA WYSOKOŚĆ
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_add, color: Colors.blue),
              title: const Text('Dodaj znajomego'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showAddFriendDialog(context);
              },
            ),
          ),
          const SizedBox(height: 16),
          // Lista znajomych - ROZSZERZALNA
          Expanded(
            child: ListView.builder(
              itemCount: state.friends.length,
              itemBuilder: (context, index) {
                final friend = state.friends[index];
                return _FriendListItem(
                  friend: friend,
                  onRemove: () {
                    _showRemoveFriendDialog(context, friend);
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  void _showAddFriendDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dodaj znajomego'),
        content: SingleChildScrollView(
          // DODANE - zapobiega overflow w dialogu
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Wpisz adres email znajomego:'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'email@przyklad.pl',
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                context.read<FriendsCubit>().sendFriendInvitation(email);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Zaproszenie wysłane do $email'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Wyślij zaproszenie'),
          ),
        ],
      ),
    );
  }

  void _showRemoveFriendDialog(BuildContext context, FriendEntity friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń znajomego'),
        content: Text(
            'Czy na pewno chcesz usunąć ${friend.friendName} z listy znajomych?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              context.read<FriendsCubit>().removeFriend(friend.friendEmail);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Usunięto ${friend.friendName} z listy znajomych'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Usuń', style: TextStyle(color: Colors.white)),
          ),
        ],
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
            Icon(
              Icons.person_add_disabled,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Brak oczekujących zaproszeń',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Zaproszenia od innych użytkowników\npojawiają się tutaj',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
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
          onAccept: () {
            _showAcceptInvitationDialog(context, invitation);
          },
          onReject: () {
            _showRejectInvitationDialog(context, invitation);
          },
        );
      },
    );
  }

  void _showAcceptInvitationDialog(
      BuildContext context, FriendInvitationEntity invitation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zaakceptuj zaproszenie'),
        content: Text(
            'Czy chcesz zaakceptować zaproszenie od ${invitation.fromUserName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              context
                  .read<FriendsCubit>()
                  .respondToInvitation(invitation.id, true);
              Navigator.pop(context);
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
      builder: (context) => AlertDialog(
        title: const Text('Odrzuć zaproszenie'),
        content: Text(
            'Czy na pewno chcesz odrzucić zaproszenie od ${invitation.fromUserName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              context
                  .read<FriendsCubit>()
                  .respondToInvitation(invitation.id, false);
              Navigator.pop(context);
            },
            child: const Text('Odrzuć', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _FriendListItem extends StatelessWidget {
  final FriendEntity friend;
  final VoidCallback onRemove;

  const _FriendListItem({
    required this.friend,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            friend.friendName.isNotEmpty
                ? friend.friendName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          friend.friendName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(friend.friendEmail),
        trailing: IconButton(
          icon: const Icon(Icons.person_remove, color: Colors.red),
          onPressed: onRemove,
          tooltip: 'Usuń znajomego',
        ),
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange[100],
                  child: Text(
                    invitation.fromUserName.isNotEmpty
                        ? invitation.fromUserName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Colors.orange[800],
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
                        ),
                      ),
                      Text(
                        invitation.fromUserEmail,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Wysłano: ${_formatDate(invitation.sentAt)}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Zaakceptuj'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
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
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: onReject,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
