import 'package:flutter/material.dart';

import 'package:baby_shop_hub/core/mysql_service.dart';
import 'package:baby_shop_hub/core/user_session.dart';

class WriteReviewScreen extends StatefulWidget {
  final String productId;

  const WriteReviewScreen({
    super.key,
    required this.productId,
  });

  @override
  State<WriteReviewScreen> createState() =>
      _WriteReviewScreenState();
}

class _WriteReviewScreenState
    extends State<WriteReviewScreen> {
  final MySQLService _mysqlService = MySQLService();
  final TextEditingController _reviewController =
      TextEditingController();

  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final userId = UserSession.loggedUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please log in to submit a review.',
          ),
        ),
      );

      return;
    }

    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a rating.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _mysqlService.addProductReview(
        productId: widget.productId,
        userId: userId,
        rating: _selectedRating,
        comment:
            _reviewController.text.trim().isEmpty
                ? null
                : _reviewController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Review submitted successfully.',
          ),
          backgroundColor: Color(0xFF13A765),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
          'Write a Review',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF273143),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          18,
          15,
          18,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How would you rate this product?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF273143),
                    ),
                  ),

                  const SizedBox(height: 18),

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
                                _selectedRating =
                                    rating;
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 5,
                              ),
                              child: Icon(
                                rating <=
                                        _selectedRating
                                    ? Icons.star_rounded
                                    : Icons
                                        .star_border_rounded,
                                size: 38,
                                color:
                                    const Color(
                                  0xFFFFB000,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      _selectedRating == 0
                          ? 'Tap a star to rate'
                          : '$_selectedRating out of 5',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF737A86),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Write your review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF273143),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Tell other customers what you think about this product.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF737A86),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: _reviewController,
                    maxLines: 6,
                    maxLength: 500,
                    textInputAction:
                        TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText:
                          'Write your review here...',
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB0B4BA),
                      ),
                      filled: true,
                      fillColor:
                          const Color(0xFFF8F8F8),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E5E5),
                        ),
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E5E5),
                        ),
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(
                          color: Color(0xFFFF6800),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    _isSubmitting
                        ? null
                        : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFF6800),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Review',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}