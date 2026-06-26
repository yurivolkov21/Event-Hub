import 'package:flutter/material.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/theme/eventhub_theme.dart';
import '../data/user_models.dart';
import '../data/user_repository.dart';

/// Searchable list of EventHub members the user can select and invite,
/// matching the Figma "Invite Friend" screen.
class InviteFriendScreen extends StatefulWidget {
  const InviteFriendScreen({
    required this.authToken,
    this.userRepository,
    super.key,
  });

  final String authToken;
  final UserRepository? userRepository;

  @override
  State<InviteFriendScreen> createState() => _InviteFriendScreenState();
}

class _InviteFriendScreenState extends State<InviteFriendScreen> {
  late final UserRepository _userRepository;
  final _searchController = TextEditingController();

  List<UserSummary> _users = [];
  final Set<String> _selectedIds = {};
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userRepository = widget.userRepository ?? UserRepository();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _userRepository.listUsers(
        authToken: widget.authToken,
        search: _searchController.text,
      );
      if (!mounted) return;
      setState(() => _users = users);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unable to load people');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggle(String userId) {
    setState(() {
      if (_selectedIds.contains(userId)) {
        _selectedIds.remove(userId);
      } else {
        _selectedIds.add(userId);
      }
    });
  }

  void _sendInvites() {
    final count = _selectedIds.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count == 1
              ? 'Invitation sent to 1 friend'
              : 'Invitations sent to $count friends',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedIds.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Invite Friend')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: hasSelection
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FilledButton(
                onPressed: _sendInvites,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 58),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('INVITE (${_selectedIds.length})'),
                    const SizedBox(width: 14),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward, size: 18),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _loadUsers(),
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  onPressed: _loadUsers,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(onRefresh: _loadUsers, child: _buildBody()),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 42,
                  color: EventHubTheme.primary,
                ),
                const SizedBox(height: 12),
                Text(_errorMessage!),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loadUsers,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_users.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 140),
          Center(child: Text('No people found')),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 96),
      itemCount: _users.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 76),
      itemBuilder: (context, index) {
        final user = _users[index];
        final selected = _selectedIds.contains(user.id);

        return ListTile(
          onTap: () => _toggle(user.id),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: EventHubTheme.primary.withValues(alpha: 0.14),
            foregroundColor: EventHubTheme.primary,
            backgroundImage:
                (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                ? Text(
                    _initials(user.fullName),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  )
                : null,
          ),
          title: Text(
            user.fullName,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            user.role == 'organizer' ? 'Organizer' : user.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(
            selected ? Icons.check_circle : Icons.circle_outlined,
            color: selected ? EventHubTheme.primary : EventHubTheme.muted,
          ),
        );
      },
    );
  }

  String _initials(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    return words
        .take(2)
        .map((word) => word.characters.first)
        .join()
        .toUpperCase();
  }
}
