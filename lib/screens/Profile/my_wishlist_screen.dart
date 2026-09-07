import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:baby_shop_hub/core/mysql_service.dart';
import 'package:baby_shop_hub/core/user_session.dart';

class MyWishlistScreen extends StatefulWidget {
  const MyWishlistScreen({super.key});

  @override
  State<MyWishlistScreen> createState() => _MyWishlistScreenState();
}

class _MyWishlistScreenState extends State<MyWishlistScreen> {
  final MySQLService _mysqlService = MySQLService();
  final UserSession _userSession = UserSession.instance;

  List<Map<String, dynamic>> _wishlistItems = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLiveWishlist();
  }

  // FETCH USER WISHLIST WITH DETAILS
  Future<void> _fetchLiveWishlist() async {
    final String? userId = _userSession.userId;
    if (userId == null || userId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final conn = await _mysqlService.connection;

      final result = await conn.execute(
        "SELECT p.id AS productId, p.name, p.price, p.brand "
        "FROM UserWishlist u "
        "JOIN Products p ON u.productId = p.id "
        "WHERE u.userId = :userId",
        {"userId": userId},
      );

      final items = result.rows.map((row) {
        final data = row.assoc();
        return {
          'productId': data['productId'] ?? '',
          'name': data['name'] ?? '',
          'price': data['price'] ?? '0.00',
          'brand': data['brand'] ?? 'Unknown',
        };
      }).toList();

      if (mounted) {
        setState(() {
          _wishlistItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not populate wishlist items: $e')),
      );
    }
  }

  // REMOVE FROM WISHLIST
  Future<void> _removeItem(String productId) async {
    final String? userId = _userSession.userId;
    if (userId == null) return;

    EasyLoading.show(status: 'Removing from wishlist...');
    try {
      // 🛑 CALLS YOUR EXACT METHOD NAME: removeFromWishlist
      final success = await _mysqlService.removeFromWishlist(
        userId: userId,
        productId: productId,
      );

      if (success) {
        EasyLoading.showSuccess('Removed!');
        _fetchLiveWishlist(); // Instantly update the user interface grid
      } else {
        EasyLoading.showError('Could not process request.');
      }
    } catch (e) {
      EasyLoading.showError('Action Failed');
    }
  }

  // MOVE ITEM INTO SHOPPING CART
  Future<void> _addItemToCart(String productId) async {
    final String? userId = _userSession.userId;
    if (userId == null) return;

    EasyLoading.show(status: 'Moving item to shopping cart...');
    try {
      final cartSuccess = await _mysqlService.addToCart(
        userId: userId,
        productId: productId,
        quantity: 1,
      );

      if (cartSuccess) {
        await _mysqlService.removeFromWishlist(
          userId: userId,
          productId: productId,
        );
        EasyLoading.showSuccess('Moved to Cart!');
        _fetchLiveWishlist();
      } else {
        EasyLoading.showError('Could not add to cart.');
      }
    } catch (e) {
      EasyLoading.showError('Transaction Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E1E24)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            color: Color(0xFF1E1E24),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _wishlistItems.isEmpty
                  ? _buildEmptyWishlistState()
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _wishlistItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                      itemBuilder: (context, index) {
                        final item = _wishlistItems[index];
                        final String pId = item['productId'] ?? '';

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.06),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFF3EC),
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(24),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.card_giftcard_rounded,
                                        size: 48,
                                        color: Colors.orange.shade200,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => _removeItem(pId),
                                        child: const CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            Icons.favorite,
                                            color: Colors.redAccent,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['brand']!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['name']!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF1E1E24),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${item['price']}',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _addItemToCart(pId),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFFF3EC),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.add_shopping_cart_rounded,
                                              color: Colors.orange,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
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

  Widget _buildEmptyWishlistState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.heart_broken_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),

          const SizedBox(height: 16),
          const Text(
            'Your Wishlist is empty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E24),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Explore baby products and tap the heart icon to save items here!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
