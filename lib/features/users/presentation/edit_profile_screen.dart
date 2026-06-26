import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/theme/eventhub_theme.dart';
import '../data/user_models.dart';
import '../data/user_repository.dart';

const _interestOptions = <String>[
  'Sports',
  'Music',
  'Food',
  'Art',
  'Movie',
  'Concert',
  'Games Online',
  'Others',
];

const _genderOptions = <String>['male', 'female', 'other'];

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    required this.authToken,
    required this.profile,
    this.userRepository,
    super.key,
  });

  final String authToken;
  final UserProfile profile;
  final UserRepository? userRepository;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final UserRepository _userRepository;
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;
  late final Set<String> _interests;

  DateTime? _dateOfBirth;
  String? _gender;
  Uint8List? _avatarBytes;
  String? _avatarFileName;
  String? _avatarMimeType;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _userRepository = widget.userRepository ?? UserRepository();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _locationController = TextEditingController(
      text: widget.profile.location ?? '',
    );
    _interests = {...widget.profile.interests};
    _dateOfBirth = widget.profile.dateOfBirth;
    _gender = _genderOptions.contains(widget.profile.gender)
        ? widget.profile.gender
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 82,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      setState(() => _errorMessage = 'Image file size must be 5MB or less');
      return;
    }

    setState(() {
      _avatarBytes = bytes;
      _avatarFileName = image.name;
      _avatarMimeType = _mimeTypeForImage(image);
      _errorMessage = null;
    });
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18),
      firstDate: DateTime(1920),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Upload a newly picked avatar first (separate multipart endpoint).
      if (_avatarBytes != null) {
        await _userRepository.uploadAvatar(
          authToken: widget.authToken,
          bytes: _avatarBytes!,
          fileName: _avatarFileName ?? 'avatar.jpg',
          mimeType: _avatarMimeType ?? 'image/jpeg',
        );
      }

      final updated = await _userRepository.updateProfile(
        authToken: widget.authToken,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        interests: _interests.toList(),
      );

      if (mounted) {
        Navigator.of(context).pop(updated);
      }
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'Unable to update profile');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _mimeTypeForImage(XFile image) {
    final mimeType = image.mimeType;
    if (mimeType != null && mimeType.startsWith('image/')) {
      return mimeType;
    }

    final name = image.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(child: _AvatarPicker(
                avatarBytes: _avatarBytes,
                avatarUrl: widget.profile.avatarUrl,
                fullName: widget.profile.fullName,
                onPick: _pickAvatar,
              )),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Full name must contain at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDateOfBirth,
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of birth',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  child: Text(
                    _dateOfBirth != null
                        ? _formatDate(_dateOfBirth!)
                        : 'Select date',
                    style: TextStyle(
                      color: _dateOfBirth != null
                          ? EventHubTheme.ink
                          : EventHubTheme.muted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.wc_outlined),
                ),
                items: _genderOptions
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value[0].toUpperCase() + value.substring(1)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _gender = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'About me',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              const SizedBox(height: 8),
              Text('Interests', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _interestOptions.map((interest) {
                  final selected = _interests.contains(interest);

                  return FilterChip(
                    label: Text(interest),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _interests.add(interest);
                        } else {
                          _interests.remove(interest);
                        }
                      });
                    },
                    selectedColor: EventHubTheme.primary.withValues(alpha: 0.16),
                    checkmarkColor: EventHubTheme.primary,
                  );
                }).toList(),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 18),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 26),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.avatarBytes,
    required this.avatarUrl,
    required this.fullName,
    required this.onPick,
  });

  final Uint8List? avatarBytes;
  final String? avatarUrl;
  final String fullName;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (avatarBytes != null) {
      image = MemoryImage(avatarBytes!);
    } else if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      image = NetworkImage(avatarUrl!);
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: 52,
          backgroundColor: EventHubTheme.primary.withValues(alpha: 0.14),
          foregroundColor: EventHubTheme.primary,
          backgroundImage: image,
          child: image == null
              ? Text(
                  _initials(fullName),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : null,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Material(
            color: EventHubTheme.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPick,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ),
          ),
        ),
      ],
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
