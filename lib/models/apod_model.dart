class ApodModel {
  final String title;
  final String date;
  final String explanation;
  final String url;
  final String mediaType;

  ApodModel({
    required this.title,
    required this.date,
    required this.explanation,
    required this.url,
    required this.mediaType,
  });

  factory ApodModel.fromJson(Map<String, dynamic> json) {
    return ApodModel(
      title: json['title'],
      date: json['date'],
      explanation: json['explanation'],
      url: json['url'],
      mediaType: json['media_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'explanation': explanation,
      'url': url,
      'media_type': mediaType,
    };
  }
}