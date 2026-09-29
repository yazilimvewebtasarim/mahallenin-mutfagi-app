import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';


class ReviewModel {
  final String id;
  final String orderId;
  final String chefId;
  final String customerId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.chefId,
    required this.customerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] ?? json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      chefId: json['chefId'] ?? '',
      customerId: json['customerId'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'chefId': chefId,
      'customerId': customerId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ReviewService {
  final Dio _dio;

  ReviewService({Dio? dio}) : _dio = dio ?? ApiClient.dio;



  Future<void> submitReview(Map<String, dynamic> reviewData) async {
    try {
      await _dio.post(
        ApiConstants.reviewsEndpoint,
        data: reviewData,
      );
    } catch (e) {
      throw Exception('Değerlendirme gönderilemedi: $e');
    }
  }

  Future<List<ReviewModel>> getChefReviews(String chefId) async {
    try {
      final response = await _dio.get('${ApiConstants.reviewsEndpoint}/$chefId');
      if (response.data is List) {
        return (response.data as List).map((e) => ReviewModel.fromJson(e)).toList();
      } else if (response.data['reviews'] is List) {
        return (response.data['reviews'] as List).map((e) => ReviewModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Değerlendirmeler alınamadı: $e');
    }
  }
}
