import 'package:flutter/material.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int _selectedRating = 0;

  final TextEditingController _reviewController =
      TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            //header
            Container(
              height: 78,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: const Color(0xFFFFF9F5),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF202938),
                    ),
                  ),

                  Positioned(
                    left: 14,
                    child: _circleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),

            //content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  6,
                  16,
                  20,
                ),
                child: Column(
                  children: [
                   //rating summary
                    _buildRatingSummary(),

                    const SizedBox(height: 12),

                    //seller rating
                    _buildSellerRating(),

                    const SizedBox(height: 12),

                    //write a review
                    _buildWriteReview(),

                    const SizedBox(height: 12),

                    //reviews
                    _buildReviewCard(
                      name: 'Sarah M.',
                      initial: 'S',
                      date: 'Aug 12, 2026',
                      rating: 5,
                      review:
                          'Absolutely love this! My baby has been so comfortable. The quality exceeded my expectations — definitely buying again.',
                    ),

                    const SizedBox(height: 10),

                    _buildReviewCard(
                      name: 'David K.',
                      initial: 'D',
                      date: 'Aug 5, 2026',
                      rating: 4,
                      review:
                          'Great quality for the price. Shipping was fast and packaging was secure. Would recommend to any new parent.',
                    ),

                    const SizedBox(height: 10),

                    _buildReviewCard(
                      name: 'Emma L.',
                      initial: 'E',
                      date: 'Jul 28, 2026',
                      rating: 5,
                      review:
                          "Third time ordering this. My pediatrician recommended it and I couldn't be happier. Works exactly as described!",
                    ),

                    const SizedBox(height: 10),

                    _buildReviewCard(
                      name: 'James R.',
                      initial: 'J',
                      date: 'Jul 20, 2026',
                      rating: 4,
                      review:
                          'Good product overall. One star off because sizing ran a little smaller than expected, but quality is excellent.',
                    ),

                    const SizedBox(height: 10),

                    _buildReviewCard(
                      name: 'Priya S.',
                      initial: 'P',
                      date: 'Jul 15, 2026',
                      rating: 5,
                      review:
                          "Best purchase I've made for my newborn. Gentle on skin, easy to use, and great value. Highly recommend!",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //rating summary

  Widget _buildRatingSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8E5E2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          //overall rating
          SizedBox(
            width: 74,
            child: Column(
              children: [
                const Text(
                  '4.6',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF182234),
                    height: 1,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  '★★★★★',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.5,
                    color: Color(0xFFFFB000),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '5 reviews',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          //rating breakdown
          Expanded(
            child: Column(
              children: [
                _ratingBar(
                  rating: '5',
                  percentage: 0.88,
                  count: '3',
                ),
                _ratingBar(
                  rating: '4',
                  percentage: 0.62,
                  count: '2',
                ),
                _ratingBar(
                  rating: '3',
                  percentage: 0,
                  count: '0',
                ),
                _ratingBar(
                  rating: '2',
                  percentage: 0,
                  count: '0',
                ),
                _ratingBar(
                  rating: '1',
                  percentage: 0,
                  count: '0',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingBar({
    required String rating,
    required double percentage,
    required String count,
  }) {
    return SizedBox(
      height: 13,
      child: Row(
        children: [
          SizedBox(
            width: 10,
            child: Text(
              rating,
              style: const TextStyle(
                fontSize: 7,
                color: Color(0xFF737B89),
              ),
            ),
          ),

          const SizedBox(width: 4),

          const Icon(
            Icons.star_rounded,
            size: 10,
            color: Color(0xFFFFB000),
          ),

          const SizedBox(width: 3),

          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEFF1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB000),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 7),

          SizedBox(
            width: 8,
            child: Text(
              count,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 7,
                color: Color(0xFF9BA1AE),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //seller rating

  Widget _buildSellerRating() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        13,
        13,
        13,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8E5E2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seller Rating',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF202938),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              // Seller avatar
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBD9),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'C',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFF6600),
                  ),
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Carter's Official Store",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF273143),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Row(
                      children: [
                        const Text(
                          '★★★★★',
                          style: TextStyle(
                            fontSize: 8,
                            letterSpacing: 0.2,
                            color: Color(0xFFFFB000),
                          ),
                        ),

                        const SizedBox(width: 5),

                        Text(
                          '4.8 · 99.2% positive',
                          style: TextStyle(
                            fontSize: 7.5,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.workspace_premium_outlined,
                size: 16,
                color: Color(0xFFFFB000),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //write a review

  Widget _buildWriteReview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        13,
        14,
        13,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8E5E2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Write a Review',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF202938),
            ),
          ),

          const SizedBox(height: 10),

          // =====================================================
          // STAR SELECTOR
          // =====================================================
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (index) {
                  final rating = index + 1;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = rating;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                      ),
                      child: Icon(
                        rating <= _selectedRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 26,
                        color: rating <= _selectedRating
                            ? const Color(0xFFFFB000)
                            : const Color(0xFFDDE1E6),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 11),

          //review text field
          Container(
            height: 67,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7EE),
              borderRadius: BorderRadius.circular(11),
            ),
            child: TextField(
              controller: _reviewController,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF273143),
              ),
              decoration: InputDecoration(
                hintText:
                    'Share your experience with this product...',
                hintStyle: const TextStyle(
                  fontSize: 9.5,
                  color: Color(0xFFA4A9B2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 14),

          //submit button
          SizedBox(
            width: double.infinity,
            height: 35,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: const Color(0xFFF0F1F3),
                disabledForegroundColor: const Color(0xFFA5ADBA),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Submit Review',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //review card

  Widget _buildReviewCard({
    required String name,
    required String initial,
    required String date,
    required int rating,
    required String review,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        13,
        12,
        13,
        10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8E5E2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //user information
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBD9),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFF6600),
                  ),
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF273143),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 7,
                        color: Color(0xFFA4A9B2),
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: List.generate(
                  5,
                  (index) {
                    return Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 10,
                      color: index < rating
                          ? const Color(0xFFFFB000)
                          : const Color(0xFFDDE1E6),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          //review text
          Text(
            review,
            style: const TextStyle(
              fontSize: 10,
              height: 1.55,
              color: Color(0xFF596273),
            ),
          ),

          const SizedBox(height: 9),

          //actions
          Row(
            children: [
              const Icon(
                Icons.thumb_up_alt_outlined,
                size: 10,
                color: Color(0xFFFFB000),
              ),

              const SizedBox(width: 3),

              const Text(
                'Helpful',
                style: TextStyle(
                  fontSize: 7,
                  color: Color(0xFF9BA1AE),
                ),
              ),

              const SizedBox(width: 14),

              const Text(
                'Report',
                style: TextStyle(
                  fontSize: 7,
                  color: Color(0xFF9BA1AE),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //header circle button

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFE8E5E2),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 14,
          color: const Color(0xFF273143),
        ),
      ),
    );
  }
}