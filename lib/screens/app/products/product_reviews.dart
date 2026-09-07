import 'package:flutter/material.dart';

import 'package:baby_shop_hub/core/mysql_service.dart';

class ProductReviewsScreen extends StatefulWidget {
  final String productId;

  const ProductReviewsScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductReviewsScreen> createState() =>
      _ProductReviewsScreenState();
}

class _ProductReviewsScreenState
    extends State<ProductReviewsScreen> {
  final MySQLService _mysqlService = MySQLService();

  bool _isLoading = true;
  String? _error;
  List<Map<String, String?>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reviews =
          await _mysqlService.getProductReviews(
        widget.productId,
      );

      if (!mounted) return;

      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
        _isLoading = false;
      });
    }
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;

    double total = 0;

    for (final review in _reviews) {
      total +=
          double.tryParse(review['rating'] ?? '0') ?? 0;
    }

    return total / _reviews.length;
  }

  int _ratingCount(int rating) {
    return _reviews.where((review) {
      final reviewRating =
          int.tryParse(review['rating'] ?? '0') ?? 0;

      return reviewRating == rating;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: Color(0xFF273143),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF273143),
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadReviews,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRatingSummary(),

              const SizedBox(height: 25),

              const Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF273143),
                ),
              ),

              const SizedBox(height: 14),

              _buildReviewsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 90,
            child: Column(
              children: [
                Text(
                  _averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF273143),
                  ),
                ),
                const SizedBox(height: 4),
                _buildStars(
                  _averageRating.round(),
                  size: 17,
                ),
                const SizedBox(height: 5),
                Text(
                  '${_reviews.length} review${_reviews.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF737A86),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5),
                _buildRatingBar(4),
                _buildRatingBar(3),
                _buildRatingBar(2),
                _buildRatingBar(1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int rating) {
    final count = _ratingCount(rating);

    final percentage = _reviews.isEmpty
        ? 0.0
        : count / _reviews.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              '$rating',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF555C68),
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.star_rounded,
            size: 13,
            color: Color(0xFFFFB000),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 6,
                backgroundColor: Color(0xFFEDEDED),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFF6800),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          SizedBox(
            width: 20,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF737A86),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF6800),
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Color(0xFFFF3D3D),
            ),
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF737A86),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadReviews,
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Color(0xFFFF6800),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_reviews.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 45,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 45,
              color: Color(0xFFB8BDC6),
            ),
            SizedBox(height: 12),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF273143),
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Be the first to review this product.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF737A86),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _reviews
          .map(
            (review) => _buildReviewCard(review),
          )
          .toList(),
    );
  }

  Widget _buildReviewCard(
    Map<String, String?> review,
  ) {
    final rating =
        int.tryParse(review['rating'] ?? '0') ?? 0;

    final comment =
        review['comment']?.trim() ?? '';

    final createdAt =
        review['createdAt'] ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE8D9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 19,
                  color: Color(0xFFFF6800),
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Customer',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF273143),
                  ),
                ),
              ),

              Text(
                createdAt.isNotEmpty
                    ? createdAt.split(' ').first
                    : '',
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFF969BA3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _buildStars(
            rating,
            size: 15,
          ),

          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              comment,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF555C68),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStars(
    int rating, {
    double size = 16,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) {
          return Icon(
            index < rating
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            size: size,
            color: const Color(0xFFFFB000),
          );
        },
      ),
    );
  }
}