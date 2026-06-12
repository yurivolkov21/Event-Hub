import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/networking/api_client.dart';
import '../data/event_models.dart';
import '../data/event_repository.dart';
import 'event_image.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({
    required this.authToken,
    this.event,
    this.eventRepository,
    super.key,
  });

  final String authToken;
  final EventItem? event;
  final EventRepository? eventRepository;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _imagePicker = ImagePicker();

  late final EventRepository _eventRepository;
  late DateTime _startAt;
  late DateTime _endAt;
  late String _categoryId;
  late String _status;

  EventImageUpload? _selectedImage;
  String? _errorMessage;
  bool _isSaving = false;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();

    final event = widget.event;
    final defaultStartAt = DateTime.now().add(const Duration(days: 1));

    _eventRepository = widget.eventRepository ?? EventRepository();
    _startAt = event?.startAt ?? defaultStartAt;
    _endAt = event?.endAt ?? defaultStartAt.add(const Duration(hours: 2));
    _categoryId = _normalizeCategoryId(event?.categoryId);
    _status = event?.status ?? 'published';

    _titleController.text = event?.title ?? '';
    _descriptionController.text = event?.description ?? '';
    _venueNameController.text = event?.venueName ?? '';
    _addressController.text = event?.address ?? '';
    _cityController.text = event?.city ?? '';
    _countryController.text = event?.country ?? '';
    _priceController.text = event == null
        ? '0'
        : event.price.toStringAsFixed(
            event.price.truncateToDouble() == event.price ? 0 : 2,
          );
    _capacityController.text = event?.capacity.toString() ?? '100';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initialDate = isStart ? _startAt : _endAt;
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      initialDate: initialDate,
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (time == null) {
      return;
    }

    setState(() {
      final selected = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      if (isStart) {
        _startAt = selected;

        if (!_endAt.isAfter(_startAt)) {
          _endAt = _startAt.add(const Duration(hours: 2));
        }
      } else {
        _endAt = selected;
      }
    });
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 82,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();

    if (bytes.length > 5 * 1024 * 1024) {
      setState(() {
        _errorMessage = 'Image file size must be 5MB or less';
      });
      return;
    }

    setState(() {
      _selectedImage = EventImageUpload(
        bytes: bytes,
        fileName: image.name,
        mimeType: _mimeTypeForImage(image),
      );
      _errorMessage = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_endAt.isAfter(_startAt)) {
      setState(() => _errorMessage = 'End date must be after start date');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final input = EventFormInput(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _categoryId,
      startAt: _startAt,
      endAt: _endAt,
      venueName: _venueNameController.text.trim(),
      address: _addressController.text.trim(),
      city: _optionalText(_cityController.text),
      country: _optionalText(_countryController.text),
      price: double.parse(_priceController.text.trim()),
      capacity: int.parse(_capacityController.text.trim()),
      status: _status,
    );

    try {
      if (_isEditing) {
        await _eventRepository.updateEvent(
          eventId: widget.event!.id,
          authToken: widget.authToken,
          input: input,
          image: _selectedImage,
        );
      } else {
        await _eventRepository.createEvent(
          authToken: widget.authToken,
          input: input,
          image: _selectedImage,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'Unable to save event');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Event' : 'Create Event')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ImagePickerSection(
                existingImageUrl: widget.event?.imageUrl,
                selectedImage: _selectedImage,
                onPickImage: _pickImage,
                onClearSelection: _selectedImage == null
                    ? null
                    : () => setState(() => _selectedImage = null),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Title must contain at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: eventCategoryOptions
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _categoryId = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Description must contain at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _DateTimeTile(
                label: 'Start',
                value: _startAt,
                onPressed: () => _pickDateTime(isStart: true),
              ),
              const SizedBox(height: 10),
              _DateTimeTile(
                label: 'End',
                value: _endAt,
                onPressed: () => _pickDateTime(isStart: false),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _venueNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Venue name',
                  prefixIcon: Icon(Icons.apartment_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Venue name must contain at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Address must contain at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _countryController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final price = double.tryParse(value?.trim() ?? '');

                        if (price == null || price < 0) {
                          return 'Invalid price';
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Capacity',
                        prefixIcon: Icon(Icons.confirmation_number_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final capacity = int.tryParse(value?.trim() ?? '');

                        if (capacity == null || capacity <= 0) {
                          return 'Invalid capacity';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'published',
                    child: Text('Published'),
                  ),
                  DropdownMenuItem(value: 'draft', child: Text('Draft')),
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('Cancelled'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(_isEditing ? 'Save event' : 'Create event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  const _ImagePickerSection({
    required this.existingImageUrl,
    required this.selectedImage,
    required this.onPickImage,
    required this.onClearSelection,
  });

  final String? existingImageUrl;
  final EventImageUpload? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback? onClearSelection;

  @override
  Widget build(BuildContext context) {
    final selected = selectedImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: selected == null
              ? EventImage(imageUrl: existingImageUrl, height: 180)
              : Image.memory(
                  selected.bytes,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickImage,
                icon: const Icon(Icons.image_outlined),
                label: Text(selected == null ? 'Choose image' : 'Change image'),
              ),
            ),
            if (onClearSelection != null) ...[
              const SizedBox(width: 10),
              IconButton.outlined(
                tooltip: 'Clear selected image',
                onPressed: onClearSelection,
                icon: const Icon(Icons.close),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  const _DateTimeTile({
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final DateTime value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.calendar_month),
      label: Row(
        children: [
          Text('$label:'),
          const SizedBox(width: 8),
          Expanded(child: Text(_formatDateTime(value))),
        ],
      ),
    );
  }
}

String _normalizeCategoryId(String? categoryId) {
  final exists = eventCategoryOptions.any(
    (category) => category.id == categoryId,
  );

  if (exists && categoryId != null) {
    return categoryId;
  }

  return eventCategoryOptions[1].id;
}

String? _optionalText(String value) {
  final trimmed = value.trim();

  return trimmed.isEmpty ? null : trimmed;
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '$day/$month/${local.year} $hour:$minute';
}

String _mimeTypeForImage(XFile image) {
  final mimeType = image.mimeType;

  if (mimeType != null && mimeType.startsWith('image/')) {
    return mimeType;
  }

  final lowerCaseName = image.name.toLowerCase();

  if (lowerCaseName.endsWith('.png')) {
    return 'image/png';
  }

  if (lowerCaseName.endsWith('.webp')) {
    return 'image/webp';
  }

  if (lowerCaseName.endsWith('.gif')) {
    return 'image/gif';
  }

  return 'image/jpeg';
}
