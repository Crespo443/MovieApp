import 'package:flutter/material.dart';
import 'package:flutter_video_app/services/admin_service.dart';

class AdminAddMovieScreen extends StatefulWidget {
  const AdminAddMovieScreen({super.key});

  @override
  State<AdminAddMovieScreen> createState() => _AdminAddMovieScreenState();
}

class _AdminAddMovieScreenState extends State<AdminAddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _releaseYearController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _backdropPathController = TextEditingController();
  final _posterPathController = TextEditingController();
  bool _isLoading = false;

  final List<String> _availableGenres = [
    'Action',
    'Comedy',
    'Drama',
    'Horror',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'Animation',
    'Documentary',
    'Family',
    'Fantasy',
    'Adventure',
    'Crime',
    'Mystery',
    'Music',
    'War',
    'Western',
    'Other',
  ];
  final List<String> _selectedGenres = [];
  final List<String> _availableTypes = [
    'upcoming',
    'now_playing',
    'trending',
    'top_rated',
  ];
  String? _selectedType;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _releaseYearController.dispose();
    _videoUrlController.dispose();
    _backdropPathController.dispose();
    _posterPathController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation for dropdown fields
    if (_selectedType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a type')));
      return;
    }

    if (_selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one genre')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AdminService.addMovie(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        videoUrl: _videoUrlController.text.trim(),
        posterPath: _posterPathController.text.trim(),
        backdropPath: _backdropPathController.text.trim(),
        genre: List<String>.from(_selectedGenres),
        type: [_selectedType!],
        rating: 0,
        releaseDate: _releaseYearController.text.trim(),
        tmdbId: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movie added successfully!')),
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add movie: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _titleController.clear();
    _descriptionController.clear();
    _releaseYearController.clear();
    _videoUrlController.clear();
    _backdropPathController.clear();
    _posterPathController.clear();
    setState(() {
      _selectedGenres.clear();
      _selectedType = null;
    });
  }

  Widget _buildGenreSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _showGenreDialog(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedGenres.isEmpty
                        ? 'Select Genres'
                        : _selectedGenres.join(', '),
                    style: TextStyle(
                      color: _selectedGenres.isEmpty ? Colors.grey[600] : null,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (_selectedGenres.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Text(
              'Please select at least one genre',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showGenreDialog() async {
    final selected = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        final tempSelected = List<String>.from(_selectedGenres);
        return AlertDialog(
          title: const Text('Select Genres'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView(
                  children:
                      _availableGenres
                          .map(
                            (genre) => CheckboxListTile(
                              value: tempSelected.contains(genre),
                              title: Text(genre),
                              onChanged: (checked) {
                                setStateDialog(() {
                                  if (checked == true) {
                                    tempSelected.add(genre);
                                  } else {
                                    tempSelected.remove(genre);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempSelected),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (selected != null) {
      setState(() {
        _selectedGenres
          ..clear()
          ..addAll(selected);
      });
    }
  }

  String? _validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a release year';
    }
    final year = int.tryParse(value);
    if (year == null) {
      return 'Please enter a valid year';
    }
    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear + 10) {
      return 'Please enter a year between 1900 and ${currentYear + 10}';
    }
    return null;
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a URL';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Movie'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.movie),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _releaseYearController,
                decoration: const InputDecoration(
                  labelText: 'Release Year',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: _validateYear,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items:
                    _availableTypes
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.replaceAll('_', ' ').toUpperCase(),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator:
                    (value) => value == null ? 'Please select a type' : null,
              ),
              const SizedBox(height: 16.0),
              _buildGenreSelector(),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Video URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.video_library),
                ),
                validator: _validateUrl,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _backdropPathController,
                decoration: const InputDecoration(
                  labelText: 'Backdrop Image URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                validator: _validateUrl,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _posterPathController,
                decoration: const InputDecoration(
                  labelText: 'Poster Image URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                validator: _validateUrl,
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Add Movie',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
