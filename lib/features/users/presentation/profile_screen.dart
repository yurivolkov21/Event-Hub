import 'package:flutter/material.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/theme/eventhub_theme.dart';
import '../data/user_models.dart';
import '../data/user_repository.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.authToken,
    this.userRepository,
    super.key,
  });

  final String authToken;
  final UserRepository? userRepository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final UserRepository _userRepository;
  UserProfile? _profile;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userRepository = widget.userRepository ?? UserRepository();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _userRepository.getMyProfile(
        authToken: widget.authToken,
      );
      setState(() => _profile = profile);
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'Unable to load profile');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openEdit() async {
    final profile = _profile;
    if (profile == null) {
      return;
    }

    final updated = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute<UserProfile>(
        builder: (_) =>
            EditProfileScreen(authToken: widget.authToken, profile: profile),
      ),
    );

    if (updated != null && mounted) {
      setState(() => _profile = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: _buildBody(),
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
                  size: 40,
                  color: EventHubTheme.primary,
                ),
                const SizedBox(height: 12),
                Text(_errorMessage!),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loadProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final profile = _profile!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        Center(
          child: CircleAvatar(
            radius: 56,
            backgroundColor: EventHubTheme.primary.withValues(alpha: 0.14),
            foregroundColor: EventHubTheme.primary,
            backgroundImage:
                (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                ? NetworkImage(profile.avatarUrl!)
                : null,
            child: (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                ? Text(
                    _initials(profile.fullName),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          profile.fullName,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          profile.email,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: EventHubTheme.muted),
        ),
        const SizedBox(height: 14),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: EventHubTheme.softBlue,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  profile.role == 'organizer'
                      ? Icons.storefront_outlined
                      : Icons.person_outline,
                  size: 18,
                  color: EventHubTheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  profile.role == 'organizer' ? 'Organizer' : 'User',
                  style: const TextStyle(
                    color: EventHubTheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: OutlinedButton.icon(
            onPressed: _openEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Profile'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(180, 50),
              foregroundColor: EventHubTheme.primary,
              side: const BorderSide(color: EventHubTheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 30),
        if (_hasDetails(profile)) ...[
          Text(
            'Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (profile.phone != null && profile.phone!.isNotEmpty)
            _DetailRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: profile.phone!,
            ),
          if (profile.location != null && profile.location!.isNotEmpty)
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Location',
              value: profile.location!,
            ),
          if (profile.dateOfBirth != null)
            _DetailRow(
              icon: Icons.cake_outlined,
              label: 'Date of birth',
              value: _formatDate(profile.dateOfBirth!),
            ),
          if (profile.gender != null && profile.gender!.isNotEmpty)
            _DetailRow(
              icon: Icons.wc_outlined,
              label: 'Gender',
              value:
                  profile.gender![0].toUpperCase() +
                  profile.gender!.substring(1),
            ),
          const SizedBox(height: 28),
        ],
        Text(
          'About Me',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          (profile.bio != null && profile.bio!.isNotEmpty)
              ? profile.bio!
              : 'No bio yet. Tap Edit Profile to tell others about yourself.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: EventHubTheme.muted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Interest',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        if (profile.interests.isEmpty)
          Text(
            'No interests selected yet.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: EventHubTheme.muted),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: profile.interests.map((interest) {
              return Chip(
                label: Text(interest),
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: EventHubTheme.primary,
                side: BorderSide.none,
              );
            }).toList(),
          ),
      ],
    );
  }

  bool _hasDetails(UserProfile profile) {
    return (profile.phone != null && profile.phone!.isNotEmpty) ||
        (profile.location != null && profile.location!.isNotEmpty) ||
        profile.dateOfBirth != null ||
        (profile.gender != null && profile.gender!.isNotEmpty);
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  String _initials(String value) {
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
        .map((word) => word.characters.first)
        .join()
        .toUpperCase();
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: EventHubTheme.softBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: EventHubTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: EventHubTheme.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
