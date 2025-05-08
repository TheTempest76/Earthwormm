import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For decoding JSON response
import 'package:project_earthworm/farmer/farmer_home.dart'; // Import the file that contains selectedLanguage

class VideosPage extends StatefulWidget {
  final String topic;

  VideosPage({required this.topic});

  @override
  _VideosPageState createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  List<dynamic> _videos = [];

  // YouTube API key (replace with your actual API key)
  final String _apiKey = 'AIzaSyBmTSzOkwRdfFPDuh1BJkYmK-lEeaJc9tk';

  // Get the selected language from FarmerHome
  Language get _selectedLanguage => FarmerHome.selectedLanguage;

  // Method to convert the Language enum to a string
  String getLanguageCode(String language) {
    switch (language.toLowerCase()) {
      case 'hindi':
        return 'hi';
      case 'english':
        return 'en';
      case 'spanish':
        return 'es';
      default:
        return 'en'; // Default to English
    }
  }

  // Fetch the videos based on the selected language and topic
  Future<void> _fetchVideos() async {
    final topicQuery = widget.topic.toLowerCase().replaceAll(' ', '+');
    final languageQuery = _selectedLanguage.toString().split('.').last.toLowerCase();  // Get string representation of the language
    final String languageCode = getLanguageCode(languageQuery);  // Convert to language code

    // Make the API call with the language code
    final url =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$topicQuery+$languageQuery+farming&type=video&key=$_apiKey&relevanceLanguage=$languageCode';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _videos = data['items'];
      });
    } else {
      throw Exception('Failed to load videos');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos for ${widget.topic}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _videos.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _videos.length,
                itemBuilder: (context, index) {
                  var video = _videos[index];
                  var title = video['snippet']['title'];
                  var description = video['snippet']['description'];
                  var videoId = video['id']['videoId'];
                  var thumbnailUrl = video['snippet']['thumbnails']['high']['url'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigate to video player on tap
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VideoPlayerPage(videoId: videoId),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12.0),
                              topRight: Radius.circular(12.0),
                            ),
                            child: Image.network(
                              thumbnailUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
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

class VideoPlayerPage extends StatefulWidget {
  final String videoId;

  VideoPlayerPage({required this.videoId});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Playing Video"),
      ),
      body: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
    );
  }
}
