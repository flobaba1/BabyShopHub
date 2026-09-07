import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:baby_shop_hub/core/mysql_service.dart';
import 'package:baby_shop_hub/core/user_session.dart';
import 'package:baby_shop_hub/utilities/models/user_card.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final MySQLService _mysqlService = MySQLService();
  final UserSession _userSession = UserSession.instance;

  List<UserCard> _savedCards = [];
  bool _isLoading = true;

  // Controllers for Add Card Form
  final _holderController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPaymentCards();
  }

  @override
  void dispose() {
    _holderController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATABASE DATA FETCHING
  // ============================================================

  Future<void> _loadPaymentCards() async {
    final String? userId = _userSession.userId;
    if (userId == null || userId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final List<UserCard> cards = await _mysqlService.getUserCards(userId);
      if (mounted) {
        setState(() {
          _savedCards = cards;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cards: ${e.toString()}')),
      );
    }
  }

  // ============================================================
  // ADD CARD DATABASE TRANSACTION
  // ============================================================

  Future<void> _saveCardToDatabase() async {
    final String? userId = _userSession.userId;
    final holder = _holderController.text.trim();
    final number = _numberController.text.trim();
    final expiry = _expiryController.text.trim();

    if (userId == null) return;

    if (holder.isEmpty || number.isEmpty || expiry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all form details.')),
      );
      return;
    }

    // Mask card digits to save only the last 4 digits securely
    final lastFour = number.length >= 4
        ? number.substring(number.length - 4)
        : '0000';

    EasyLoading.show(status: 'Saving card details...');
    try {
      final success = await _mysqlService.addUserCard(
        userId: userId,
        cardHolder: holder,
        cardLastFour: lastFour,
        expiryDate: expiry,
        cardToken: 'tok_mock_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (success) {
        EasyLoading.showSuccess('Card added successfully!');
        _holderController.clear();
        _numberController.clear();
        _expiryController.clear();
        _cvvController.clear();

        Navigator.pop(context); // Close BottomSheet
        _loadPaymentCards(); // Refresh List view
      } else {
        EasyLoading.showError('Could not save card.');
      }
    } catch (e) {
      EasyLoading.showError('Transaction Error');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // ============================================================
  // DELETE CARD TRANSACTION
  // ============================================================

  Future<void> _deleteCard(String cardId) async {
    EasyLoading.show(status: 'Removing card...');
    try {
      final success = await _mysqlService.deleteUserCard(cardId);
      if (success) {
        EasyLoading.showSuccess('Card deleted.');
        _loadPaymentCards(); // Reload state arrays fresh
      } else {
        EasyLoading.showError('Could not delete card.');
      }
    } catch (e) {
      EasyLoading.showError('Action failed');
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
          'Payment Methods',
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
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saved Cards',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E24),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Renders list dynamically if items exist, otherwise displays placeholder text
                    _savedCards.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _savedCards.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final card = _savedCards[index];
                              // Cycle visual themes depending on card sequence layout indices
                              final useDarkTheme = index % 2 != 0;
                              return _buildCreditCard(
                                cardId: card.id ?? '',
                                cardHolder: card.cardHolder,
                                cardNumber:
                                    '•••• •••• •••• ${card.cardLastFour}',
                                expiry: card.expiryDate,
                                brand: card.cardLastFour.startsWith('4')
                                    ? 'Visa'
                                    : 'Mastercard',
                                colors: useDarkTheme
                                    ? [
                                        const Color(0xFF37474F),
                                        const Color(0xFF212121),
                                      ]
                                    : [
                                        const Color(0xFFFF9100),
                                        const Color(0xFFFF3D00),
                                      ],
                              );
                            },
                          ),
                    const SizedBox(height: 32),

                    OutlinedButton.icon(
                      onPressed: () => _showAddCardBottomSheet(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.orange,
                          width: 1.5,
                        ),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(
                        Icons.add_card_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                      label: const Text(
                        'Add New Payment Card',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCreditCard({
    required String cardId,
    required String cardHolder,
    required String cardNumber,
    required String expiry,
    required String brand,
    required List<Color> colors,
  }) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.contactless_rounded,
                color: Colors.white,
                size: 28,
              ),
              Text(
                brand,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          Text(
            cardNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARD HOLDER',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cardHolder,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expiry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () => _deleteCard(cardId),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.06)),
      ),
      child: const Center(
        child: Text(
          'No saved cards found. Tap below to add one.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }

  void _showAddCardBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add New Card',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E24),
              ),
            ),
            const SizedBox(height: 20),
            _buildModalInput(
              'Cardholder Name',
              'e.g. Emma Johnson',
              controller: _holderController,
            ),
            const SizedBox(height: 16),
            _buildModalInput(
              'Card Number',
              '0000 0000 0000 0000',
              icon: Icons.credit_card_outlined,
              controller: _numberController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildModalInput(
                    'Expiry Date',
                    'MM/YY',
                    controller: _expiryController,
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModalInput(
                    'CVV',
                    '123',
                    obscure: true,
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveCardToDatabase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Add Card Securely',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalInput(
    String label,
    String placeholder, {
    required TextEditingController controller,
    IconData? icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: Colors.grey.withOpacity(0.5),
              fontSize: 14,
            ),
            prefixIcon: icon != null
                ? Icon(icon, color: Colors.orange.shade300, size: 20)
                : null,
            filled: true,
            fillColor: const Color(0xFFFFF8F4),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.orange),
            ),
          ),
        ),
      ],
    );
  }
}
