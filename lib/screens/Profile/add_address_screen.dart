import 'package:flutter/material.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  // FIXED: Added the missing state variable for the dropdown selection
  String _selectedCountry = 'United States';

  // Pre-populated text controllers representing your active primary address lines
  final _line1Controller = TextEditingController(text: '123 Maple Street');
  final _line2Controller = TextEditingController(text: 'Apt 4B');
  final _cityController = TextEditingController(text: 'Springfield');
  final _stateController = TextEditingController(text: 'IL');
  final _zipController = TextEditingController(text: '62701');

  @override
  void dispose() {
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
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
          'Edit Delivery Address',
          style: TextStyle(
            color: Color(0xFF1E1E24),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Modify Shipping Destination',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Only the pure physical address properties are exposed as text entry forms
              _buildEditableAddressInput('Address Line 1', _line1Controller),
              const SizedBox(height: 16),
              _buildEditableAddressInput(
                'Address Line 2 (Optional)',
                _line2Controller,
              ),
              const SizedBox(height: 16),
              _buildEditableAddressInput('City', _cityController),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildEditableAddressInput(
                      'State',
                      _stateController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    // FIXED: Changed _buildFormInput to the correct name _buildEditableAddressInput
                    child: _buildEditableAddressInput(
                      'ZIP Code',
                      _zipController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'Country',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                // FIXED: Repaired the broken layout blocks and closed the dropdown hierarchy cleanly
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountry,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items:
                        [
                          'United States',
                          'Nigeria',
                          'United Kingdom',
                          'Canada',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 15),
                            ),
                          );
                        }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCountry = val!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Save Action bottom button layout
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6D00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Address Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableAddressInput(
    String label,
    TextEditingController controller,
  ) {
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
          decoration: InputDecoration(
            // FIXED: Replaced undefined variable placeholder with label
            hintText: label,
            hintStyle: TextStyle(
              color: Colors.grey.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.withValues(alpha: 0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFFF6D00)),
            ),
          ),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E24),
          ),
        ),
      ],
    );
  }
}
