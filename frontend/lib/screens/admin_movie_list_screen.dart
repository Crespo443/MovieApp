import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_video_app/models/video_model.dart';
import 'package:flutter_video_app/services/api_service.dart';
import 'package:flutter_video_app/screens/admin_edit_movie_screen.dart';
import 'package:flutter_video_app/screens/admin_add_movie_screen.dart';

class AdminMovieListScreen extends StatefulWidget {
  const AdminMovieListScreen({super.key});

  @override
  State<AdminMovieListScreen> createState() => _AdminMovieListScreenState();
}

class _AdminMovieListScreenState extends State<AdminMovieListScreen> {
  final List<VideoModel> _movies = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;
  String _searchQuery = '';
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMovies(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isLoading) {
      _fetchMovies();
    }
  }

  Future<void> _fetchMovies({bool reset = false}) async {
    if (_isLoading || _isLoadingMore) return;
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
        _hasMore = true;
        _movies.clear();
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }
    try {
      final movies = await ApiService.getVideos(
        page: _currentPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      setState(() {
        if (reset) {
          _movies.clear();
        }
        _movies.addAll(movies);
        _hasMore = movies.length >= 20; // page size
        if (_hasMore) _currentPage++;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value.trim();
      });
      _fetchMovies(reset: true);
    });
  }

  Future<void> _editMovie(VideoModel movie) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminEditMovieScreen(movie: movie),
      ),
    );
    if (result == true) {
      _fetchMovies(reset: true);
    }
  }

  Future<void> _deleteMovie(VideoModel movie) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Movie'),
            content: Text('Are you sure you want to delete "${movie.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
    if (confirm != true) return;
    try {
      await ApiService.deleteMovieByAdmin(movie.tmdbId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movie deleted successfully!')),
        );
        _fetchMovies(reset: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete movie: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Movie List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminAddMovieScreen(),
            ),
          );
          if (result == true) {
            _fetchMovies(reset: true);
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Movie',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search movies...',
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[850], // Changed to dark color
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              style: const TextStyle(
                color: Colors.white,
              ), // Ensure input text is white
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child:
                _isLoading && _movies.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : RefreshIndicator(
                      onRefresh: () => _fetchMovies(reset: true),
                      child: ListView.separated(
                        controller: _scrollController,
                        itemCount:
                            _movies.length +
                            (_isLoadingMore || _hasMore ? 1 : 0),
                        separatorBuilder:
                            (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          if (index >= _movies.length) {
                            if (_isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            } else if (_hasMore) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: Text('Load more...')),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }
                          final movie = _movies[index];
                          return ListTile(
                            leading:
                                movie.posterPath.isNotEmpty
                                    ? Image.network(
                                      movie.posterPath,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    )
                                    : const Icon(Icons.movie, size: 50),
                            title: Text(movie.title),
                            subtitle: Text(movie.genre.join(', ')),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _editMovie(movie),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteMovie(movie),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
