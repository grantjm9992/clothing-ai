import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/providers.dart';
import 'outfit_feedback_screen.dart';

class FitCheckScreen extends ConsumerStatefulWidget {
  const FitCheckScreen({super.key});

  @override
  ConsumerState<FitCheckScreen> createState() => _FitCheckScreenState();
}

class _FitCheckScreenState extends ConsumerState<FitCheckScreen> {
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  final _occasionController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedVibe = 'Smart Casual';
  String _selectedLocation = 'Indoor';
  String? _whoWith;

  final List<String> vibes = [
    'Smart Casual',
    'Formal',
    'Business',
    'Casual',
    'Relaxed',
    'Edgy',
    'Trendy',
    'Classic',
  ];

  final List<String> locations = ['Indoor', 'Outdoor', 'Mixed'];

  @override
  void dispose() {
    _occasionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fit Check'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Take a photo of your outfit', style: AppTheme.h2),
              const SizedBox(height: 12),
              Text(
                'Get AI-powered feedback on your outfit choice',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),

              // Photo capture area
              _buildPhotoArea(),
              const SizedBox(height: 32),

              Text('Tell us about the occasion', style: AppTheme.h3),
              const SizedBox(height: 16),

              // Occasion
              TextFormField(
                controller: _occasionController,
                decoration: const InputDecoration(
                  labelText: 'Occasion',
                  hintText: 'e.g., Dinner with friends',
                  prefixIcon: Icon(Icons.event),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an occasion';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Vibe selection
              Text('Desired Vibe', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: vibes.map((vibe) {
                  final isSelected = vibe == _selectedVibe;
                  return ChoiceChip(
                    label: Text(vibe),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedVibe = vibe);
                    },
                    backgroundColor: AppTheme.surface,
                    selectedColor: AppTheme.accent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Location
              Text('Location', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: locations.map((loc) {
                  return ButtonSegment(
                    value: loc,
                    label: Text(loc),
                  );
                }).toList(),
                selected: {_selectedLocation},
                onSelectionChanged: (Set<String> selection) {
                  setState(() => _selectedLocation = selection.first);
                },
              ),
              const SizedBox(height: 24),

              // Who with
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Who are you with? (optional)',
                  hintText: 'e.g., Friends, colleagues, date',
                  prefixIcon: Icon(Icons.people),
                ),
                onChanged: (value) => _whoWith = value,
              ),
              const SizedBox(height: 16),

              // Additional notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional notes (optional)',
                  hintText: 'Any specific concerns or questions?',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _imageFile != null ? _submitForFeedback : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Get AI Feedback'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoArea() {
    if (_imageFile != null) {
      return Stack(
        children: [
          Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: FileImage(_imageFile!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.7),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => setState(() => _imageFile = null),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text('No photo yet', style: AppTheme.h3),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera),
                label: const Text('Camera'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _submitForFeedback() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Analyzing your outfit...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // TODO: Upload image and create session
      // For now, simulate
      await Future.delayed(const Duration(seconds: 2));

      final context = {
        'occasion': _occasionController.text,
        'vibe': _selectedVibe,
        'location': _selectedLocation,
        if (_whoWith != null && _whoWith!.isNotEmpty) 'whoWith': _whoWith,
        'notes': _notesController.text,
      };

      // Navigate to feedback screen
      if (mounted) {
        Navigator.of(this.context).pop(); // Close loading dialog
        Navigator.of(this.context).push(
          MaterialPageRoute(
            builder: (context) => const OutfitFeedbackScreen(
              sessionId: 'demo-session-id',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}
