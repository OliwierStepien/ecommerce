// presentation/user_info/pages/user_info_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/domain/auth/entity/user_entity.dart';
import 'package:mealapp/domain/friends/entity/friend_entity.dart';
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
      body: SingleChildScrollView(
        child: BlocBuilder<UserInfoDisplayCubit, UserInfoDisplayState>(
          builder: (context, state) {
            if (state is UserInfoLoading) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is UserInfoLoaded) {
              return _UserInfoContent(user: state.user);
            }

            if (state is LoadUserInfoFailure) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Błąd ładowania danych',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: null, // Dodaj retry logikę
                        child: Text('Spróbuj ponownie'),
                      ),
                    ],
                  ),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoCard(
            title: 'Dane osobowe',
            children: [
              _InfoRow(
                label: 'Imię',
                value: user.firstName,
              ),
              _InfoRow(
                label: 'Email',
                value: user.email,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _FriendsCard(),
        ],
      ),
    );
  }
}

class _FriendsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsCubit, FriendsState>(
      builder: (context, state) {
        return _InfoCard(
          title: 'Znajomi',
          children: [
            // 👇 PRZYCISK DODAJ ZNAJOMEGO
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.blue),
              title: const Text('Dodaj znajomego'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showAddFriendDialog(context);
              },
            ),
            const SizedBox(height: 12),

            // 👇 LISTA ZNAJOMYCH
            if (state is FriendsLoading)
              const Center(child: CircularProgressIndicator()),

            if (state is FriendsLoaded)
              ...state.friends
                  .map((friend) => _FriendListItem(
                        friend: friend,
                        onRemove: () {
                          context
                              .read<FriendsCubit>()
                              .removeFriend(friend.friendEmail);
                        },
                      ))
                  .toList(),

            if (state is FriendsLoaded && state.friends.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Brak znajomych. Dodaj pierwszego znajomego!',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            if (state is FriendsError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dodaj znajomego'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Wpisz adres email znajomego:'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'email@przyklad.pl',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
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
                context.read<FriendsCubit>().addFriend(email);
                Navigator.pop(context);
              }
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
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
      ),
    );
  }
}

// 👇 _FriendListItem - DOPASOWANY DO RESZTY KODU
class _FriendListItem extends StatelessWidget {
  final FriendEntity friend;
  final VoidCallback onRemove;

  const _FriendListItem({
    required this.friend,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Text(
          friend.friendName[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(friend.friendName),
      subtitle: Text(friend.friendEmail),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
        onPressed: onRemove,
      ),
    );
  }
}
