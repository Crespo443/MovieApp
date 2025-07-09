import 'package:flutter/material.dart';
import 'package:flutter_video_app/models/comment_model.dart';
import 'package:flutter_video_app/services/api_service.dart';

class AdminUnrepliedCommentsScreen extends StatefulWidget {
  const AdminUnrepliedCommentsScreen({super.key});

  @override
  State<AdminUnrepliedCommentsScreen> createState() =>
      _AdminUnrepliedCommentsScreenState();
}

class _AdminUnrepliedCommentsScreenState
    extends State<AdminUnrepliedCommentsScreen> {
  List<ReviewModel> _comments = [];
  Map<String, String> _movieTitles = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCommentsAndMovies();
  }

  Future<void> _fetchCommentsAndMovies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final comments = await ApiService.getUnrepliedComments();
      // Fetch all movies (could be optimized for large DB)
      final allMovies = await ApiService.getVideos();
      // Map both tmdbId and id to the movie title for robust lookup
      final movieMap = <String, String>{};
      for (var m in allMovies) {
        if (m.tmdbId.isNotEmpty) movieMap[m.tmdbId] = m.title;
        if (m.id != null && m.id!.isNotEmpty) movieMap[m.id!] = m.title;
      }
      setState(() {
        _comments = comments;
        _movieTitles = movieMap;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteComment(ReviewModel comment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Comment'),
            content: Text('Are you sure you want to delete this comment?'),
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
      await ApiService.deleteCommentByAdmin(comment.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted successfully!')),
        );
        _fetchCommentsAndMovies();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete comment: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _replyToComment(ReviewModel comment) async {
    final TextEditingController _replyController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reply to Comment'),
            content: TextField(
              controller: _replyController,
              decoration: const InputDecoration(
                hintText: 'Enter your reply...',
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(context, _replyController.text.trim()),
                child: const Text('Reply'),
              ),
            ],
          ),
    );
    if (result != null && result.isNotEmpty) {
      try {
        await ApiService.addComment(
          comment.videoId,
          result,
          0.0, // Admin reply, no rating
          parentId: comment.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Reply sent!')));
          _fetchCommentsAndMovies();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to reply: \\${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unreplied Comments'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Error: $_error'))
              : _comments.isEmpty
              ? const Center(child: Text('No unreplied comments.'))
              : RefreshIndicator(
                onRefresh: _fetchCommentsAndMovies,
                child: ListView.separated(
                  itemCount: _comments.length,
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    final movieTitle =
                        _movieTitles[comment.videoId]?.isNotEmpty == true
                            ? _movieTitles[comment.videoId]!
                            : 'Unknown Movie';
                    return ListTile(
                      title: Text(comment.comment),
                      subtitle: Text(
                        'User: ${comment.userName} | Movie: $movieTitle | Rating: ${comment.rating.toStringAsFixed(1)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.reply, color: Colors.green),
                            onPressed: () => _replyToComment(comment),
                            tooltip: 'Reply',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteComment(comment),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
