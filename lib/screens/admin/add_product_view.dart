import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'admin_product_view.dart';

class AddProductScreen extends StatefulWidget {
  final AdminProduct? productToEdit; // Null if adding new, populated if editing

  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _brandController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;

  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  String _selectedCategory = 'Diapers & Wipes';
  final List<String> _categories = [
    'Diapers & Wipes',
    'Baby Food & Formula',
    'Clothing',
    'Toys & Gear',
    'Bath & Skincare',
  ];

  @override
  void initState() {
    super.initState();
    
    // Pre-fill controllers if editing an existing product
    final product = widget.productToEdit;
    _titleController = TextEditingController(text: product?.title ?? '');
    _brandController = TextEditingController(text: product?.brand ?? '');
    
    // Clean price string (e.g., "$24.99" -> "24.99")
    _priceController = TextEditingController(
      text: product?.price.replaceAll('\$', '') ?? '',
    );
    
    // Clean stock string (e.g., "Stock: 142" -> "142")
    _stockController = TextEditingController(
      text: product?.stock.replaceAll('Stock: ', '') ?? '',
    );
    
    _descriptionController = TextEditingController();
    _selectedImageBytes = product?.imageBytes;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final updatedProduct = AdminProduct(
        title: _titleController.text,
        brand: _brandController.text,
        price: '\$${_priceController.text}',
        stock: 'Stock: ${_stockController.text}',
        status: 'In Stock',
        imageUrl: widget.productToEdit?.imageUrl, // Keep asset image if untouched
        imageBytes: _selectedImageBytes,
      );

      final isEditing = widget.productToEdit != null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Product updated successfully!'
                : 'Product added successfully!',
          ),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );

      Navigator.pop(context, updatedProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Product' : 'Add New Product',
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: _selectedImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              _selectedImageBytes!,
                              width: double.infinity,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          )
                        : widget.productToEdit?.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  widget.productToEdit!.imageUrl!,
                                  width: double.infinity,
                                  height: 140,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildPlaceholder(),
                                ),
                              )
                            : _buildPlaceholder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel('Product Title'),
              TextFormField(
                controller: _titleController,
                decoration: _buildInputDecoration('e.g., Huggies Little Snugglers'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 14),
              _buildLabel('Brand'),
              TextFormField(
                controller: _brandController,
                decoration: _buildInputDecoration('e.g., Huggies'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter a brand' : null,
              ),
              const SizedBox(height: 14),
              _buildLabel('Category'),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
                decoration: _buildInputDecoration('Select Category'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Price (\$)'),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _buildInputDecoration('24.99'),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Stock Quantity'),
                        TextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('100'),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildLabel('Description'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration:
                    _buildInputDecoration('Enter product details and features...'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5722),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isEditing ? 'Update Product' : 'Save Product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.add_a_photo_outlined,
          size: 36,
          color: Color(0xFFFF5722),
        ),
        SizedBox(height: 8),
        Text(
          'Upload Product Image',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF5722), width: 1.5),
      ),
    );
  }
}