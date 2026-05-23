import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String title;
  final String subtitle;
  final String description;
  final List<String> specs;
  final String imageUrl;
  final String pdfUrl;

  const ProductModel({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.specs,
    required this.imageUrl,
    required this.pdfUrl,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return ProductModel(
      title: data?['title'] as String? ?? '',
      subtitle: data?['subtitle'] as String? ?? '',
      description: data?['description'] as String? ?? '',
      specs: List<String>.from(data?['specs'] as List<dynamic>? ?? []),
      imageUrl: data?['imageUrl'] as String? ?? '',
      pdfUrl: data?['pdfUrl'] as String? ?? '',
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      description: map['description'] as String? ?? '',
      specs: List<String>.from(map['specs'] as List<dynamic>? ?? []),
      imageUrl: map['imageUrl'] as String? ?? '',
      pdfUrl: map['pdfUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'specs': specs,
      'imageUrl': imageUrl,
      'pdfUrl': pdfUrl,
    };
  }

  String get effectivePdfUrl {
    if (pdfUrl.isNotEmpty) {
      return pdfUrl;
    }

    final normalized = imageUrl.toLowerCase();
    if (normalized.endsWith('.jpg') || normalized.endsWith('.jpeg') || normalized.endsWith('.png')) {
      return imageUrl.replaceFirst(RegExp(r'\.(jpg|jpeg|png)$', caseSensitive: false), '.pdf');
    }

    return '';
  }
}
