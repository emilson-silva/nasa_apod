import 'package:flutter/material.dart';
import '../models/apod_model.dart';
import '../services/nasa_api_services.dart';

class ApodViewModel extends ChangeNotifier {
  ApodModel? apodData;
  bool isLoading = false;
  String? errorMessage;
  DateTime selectedDate = DateTime.now();

  Future<void> fetchApod() async {
    isLoading = true;
    notifyListeners();

    try {
      apodData = await NasaApiServices.fetchApod(selectedDate);
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to load APOD. Please check your internet connection and try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }
}