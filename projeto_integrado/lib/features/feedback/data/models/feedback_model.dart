class FeedbackModel {
  final String? id;
  final String author;
  final int rating;
  final String description;
  final String category;
  final DateTime date;
  final String sentiment;
  final bool isClassified;
  final double sentimentConfidence;

  FeedbackModel({
    this.id,
    required this.author,
    required this.rating,
    required this.description,
    required this.category,
    required this.date,
    this.sentiment = 'NEUTRO',
    this.isClassified = false,
    this.sentimentConfidence = 0.0,
  });

  FeedbackModel copyWith({
    String? id,
    String? author,
    int? rating,
    String? description,
    String? category,
    DateTime? date,
    String? sentiment,
    bool? isClassified,
    double? sentimentConfidence,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      author: author ?? this.author,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      sentiment: sentiment ?? this.sentiment,
      isClassified: isClassified ?? this.isClassified,
      sentimentConfidence: sentimentConfidence ?? this.sentimentConfidence,
    );
  }

  bool isValid() {
    return author.trim().isNotEmpty &&
        category.trim().isNotEmpty &&
        description.trim().length >= 10 &&
        rating >= 1 &&
        rating <= 5;
  }
}
