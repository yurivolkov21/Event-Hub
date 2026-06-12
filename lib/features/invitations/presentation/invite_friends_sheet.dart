import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/networking/api_client.dart';
import '../../users/data/user_models.dart';
import '../../users/data/user_repository.dart';
import '../data/invitation_repository.dart';

Future<bool?> showInviteFriendsSheet({
  required BuildContext context,
  required String authToken,
  required String eventId,
  UserRepository? userRepository,
  InvitationRepository? invitationRepository,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return InviteFriendsSheet(
        authToken: authToken,
        eventId: eventId,
        userRepository: userRepository,
        invitationRepository: invitationRepository,
      );
    },
  );
}

class InviteFriendsSheet extends StatefulWidget {
  const InviteFriendsSheet({
    required this.authToken,
    required this.eventId,
    this.userRepository,
    this.invitationRepository,
    super.key,
  });

  final String authToken;
  final String eventId;
  final UserRepository? userRepository;
  final InvitationRepository? invitationRepository;

  @override
  State<InviteFriendsSheet> createState() => _InviteFriendsSheetState();
}

class _InviteFriendsSheetState extends State<InviteFriendsSheet> {
  late final UserRepository _userRepository;
  late final InvitationRepository _invitationRepository;
  final _searchController = TextEditingController();
  final _selectedUserIds = <String>{};

  Timer? _searchDebounce;
  List<UserSummary> _users = const [];
  String? _errorMessage;
  bool _isLoadingUsers = true;
  bool _isInviting = false;

  @override
  void initState() {
    super.initState();
    _userRepository = widget.userRepository ?? UserRepository();
    _invitationRepository =
        widget.invitationRepository ?? InvitationRepository();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({String? search}) async {
    setState(() {
      _isLoadingUsers = true;
      _errorMessage = null;
    });

    try {
      final users = await _userRepository.listUsers(
        authToken: widget.authToken,
        search: search,
      );

      if (mounted) {
        setState(() {
          _users = users;
        });
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Unable to load users');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingUsers = false);
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _loadUsers(search: value);
    });
  }

  Future<void> _inviteSelectedUsers() async {
    if (_selectedUserIds.isEmpty || _isInviting) {
      return;
    }

    setState(() {
      _isInviting = true;
      _errorMessage = null;
    });

    try {
      await _invitationRepository.createInvitations(
        authToken: widget.authToken,
        eventId: widget.eventId,
        userIds: _selectedUserIds.toList(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Unable to send invitations');
      }
    } finally {
      if (mounted) {
        setState(() => _isInviting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 20),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invite friends',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search by name or email',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            _loadUsers();
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Expanded(child: _buildUserList(context)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selectedUserIds.isEmpty || _isInviting
                      ? null
                      : _inviteSelectedUsers,
                  icon: _isInviting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add_alt_1),
                  label: Text(
                    _isInviting
                        ? 'Sending...'
                        : 'Invite ${_selectedUserIds.length}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context) {
    if (_isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_users.isEmpty) {
      return Center(
        child: Text(
          'No users found',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.separated(
      itemCount: _users.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = _users[index];
        final isSelected = _selectedUserIds.contains(user.id);

        return CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                _selectedUserIds.add(user.id);
              } else {
                _selectedUserIds.remove(user.id);
              }
            });
          },
          secondary: CircleAvatar(
            child: Text(_initialsFromName(user.fullName)),
          ),
          title: Text(user.fullName),
          subtitle: Text(user.email),
        );
      },
    );
  }
}

String _initialsFromName(String value) {
  final words = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();

  if (words.isEmpty) {
    return '?';
  }

  return words
      .take(2)
      .map((word) => word.characters.first.toUpperCase())
      .join();
}
