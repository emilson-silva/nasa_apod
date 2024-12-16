import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nasa_apod/views/favorites_viewer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/apod_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
@override
  void initState() {
    super.initState();
    final apodViewModel = Provider.of<ApodViewModel>(context, listen: false);
    apodViewModel.fetchApod(); 
  }

  Future<void> _selectDate(BuildContext context, ApodViewModel apodViewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1995, 6, 16),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != apodViewModel.selectedDate) {
      apodViewModel.setSelectedDate(picked);
      await apodViewModel.fetchApod();
    }
  }

  Future<void> _saveFavorite(ApodViewModel apodViewModel) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    favorites.add(jsonEncode(apodViewModel.apodData!.toJson())); // Convert to JSON string
    await prefs.setStringList('favorites', favorites);
  }

  @override
  Widget build(BuildContext context) {
    final apodViewModel = context.watch<ApodViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('NASA APOD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesView()),
              );
            },
          ),
        ],
      ),
      body: apodViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : apodViewModel.errorMessage != null
              ? Center(child: Text(apodViewModel.errorMessage!))
              : apodViewModel.apodData != null
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              apodViewModel.apodData!.title,
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              apodViewModel.apodData!.date,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            if (apodViewModel.apodData!.mediaType == 'image')
                              InteractiveViewer(
                                child: CachedNetworkImage(
                                  imageUrl: apodViewModel.apodData!.url,
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (apodViewModel.apodData!.mediaType == 'video')
                              YoutubePlayer(
                                controller: YoutubePlayerController(
                                  initialVideoId: YoutubePlayer.convertUrlToId(apodViewModel.apodData!.url)!,
                                  flags: const YoutubePlayerFlags(
                                    autoPlay: false,
                                    mute: false,
                                  ),
                                ),
                                showVideoProgressIndicator: true,
                              ),
                            const SizedBox(height: 10),
                            Text(
                              apodViewModel.apodData!.explanation,
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => _saveFavorite(apodViewModel),
                              child: const Text('Salvar como Favorito'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Center(child: Text('Nenhum dado disponível')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _selectDate(context, apodViewModel),
        child: const Icon(Icons.calendar_today),
      ),
    );
  }
}