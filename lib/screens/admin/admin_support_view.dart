import 'package:flutter/material.dart';

import 'package:baby_shop_hub/core/mysql_service.dart';

class AdminSupportView extends StatefulWidget {
  const AdminSupportView({super.key});

  @override
  State<AdminSupportView> createState() => _AdminSupportViewState();
}

class _AdminSupportViewState extends State<AdminSupportView> {
  final MySQLService _dbService = MySQLService();

  List<Map<String, dynamic>> _requests = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSupportRequests();
  }

  Future<void> _loadSupportRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final requests = await _dbService.getAllUserSupportRequests();

      if (!mounted) return;

      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF5722),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to load support requests.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSupportRequests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSupportRequests,
      color: const Color(0xFFFF5722),
      child: _requests.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Icon(
                  Icons.support_agent_outlined,
                  size: 60,
                  color: Color(0xFFD1D5DB),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'No support requests yet.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final request = _requests[index];

                return _buildSupportCard(request);
              },
            ),
    );
  }

  Widget _buildSupportCard(Map<String, dynamic> request) {
    final String status =
        request['status']?.toString() ?? 'open';

    final String category =
        request['category']?.toString() ?? 'General Feedback';

    final String subject =
        request['subject']?.toString() ?? 'No subject';

    final String message =
        request['message']?.toString() ?? '';

    final String fullName =
        request['fullName']?.toString() ?? 'Unknown User';

    final String email =
        request['email']?.toString() ?? '';

    final String createdAt =
        request['createdAt']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF3F4F6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showSupportDetails(request);
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3EC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFFFF5722),
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildStatusBadge(status),
                ],
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF5722),
                  ),
                ),
              ),

              const SizedBox(height: 9),

              Text(
                subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(createdAt),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const Row(
                    children: [
                      Text(
                        'View details',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF5722),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: Color(0xFFFF5722),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color background;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'in_progress':
        background = const Color(0xFFFFF4E5);
        textColor = const Color(0xFFD97706);
        label = 'In Progress';
        break;

      case 'resolved':
        background = const Color(0xFFECFDF5);
        textColor = const Color(0xFF059669);
        label = 'Resolved';
        break;

      case 'closed':
        background = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        label = 'Closed';
        break;

      case 'open':
      default:
        background = const Color(0xFFFFE4E6);
        textColor = const Color(0xFFE11D48);
        label = 'Open';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Future<void> _showSupportDetails(
    Map<String, dynamic> request,
  ) async {
    final responseController = TextEditingController(
      text: request['adminResponse']?.toString() ?? '',
    );

    String selectedStatus =
        request['status']?.toString() ?? 'open';

    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final String fullName =
                request['fullName']?.toString() ??
                    'Unknown User';

            final String email =
                request['email']?.toString() ?? '';

            final String category =
                request['category']?.toString() ??
                    'General Feedback';

            final String subject =
                request['subject']?.toString() ??
                    'No subject';

            final String message =
                request['message']?.toString() ?? '';

            return Container(
              height:
                  MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBF7),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Container(
                      width: 42,
                      height: 5,
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        16,
                        12,
                        12,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Support Request',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.fromLTRB(
                          20,
                          4,
                          20,
                          30,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _detailLabel('Customer'),
                            const SizedBox(height: 5),
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),

                            const SizedBox(height: 18),

                            _detailLabel('Category'),
                            const SizedBox(height: 5),
                            _categoryChip(category),

                            const SizedBox(height: 18),

                            _detailLabel('Subject'),
                            const SizedBox(height: 6),
                            Text(
                              subject,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),

                            const SizedBox(height: 18),

                            _detailLabel('Message'),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFFF3F4F6,
                                  ),
                                ),
                              ),
                              child: Text(
                                message,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            _detailLabel('Status'),
                            const SizedBox(height: 7),

                            DropdownButtonFormField<String>(
                              value: selectedStatus,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'open',
                                  child: Text('Open'),
                                ),
                                DropdownMenuItem(
                                  value: 'in_progress',
                                  child: Text('In Progress'),
                                ),
                                DropdownMenuItem(
                                  value: 'resolved',
                                  child: Text('Resolved'),
                                ),
                                DropdownMenuItem(
                                  value: 'closed',
                                  child: Text('Closed'),
                                ),
                              ],
                              onChanged: isSaving
                                  ? null
                                  : (value) {
                                      if (value == null) {
                                        return;
                                      }

                                      setSheetState(() {
                                        selectedStatus =
                                            value;
                                      });
                                    },
                            ),

                            const SizedBox(height: 20),

                            _detailLabel(
                              'Admin Response',
                            ),
                            const SizedBox(height: 7),

                            TextField(
                              controller: responseController,
                              maxLines: 5,
                              enabled: !isSaving,
                              decoration: InputDecoration(
                                hintText:
                                    'Write a response to the customer...',
                                hintStyle: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9CA3AF),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding:
                                    const EdgeInsets.all(14),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                                focusedBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(
                                    color: Color(0xFFFF5722),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isSaving
                                    ? null
                                    : () async {
                                        setSheetState(() {
                                          isSaving = true;
                                        });

                                        try {
                                          final supportId =
                                              request['id']
                                                  ?.toString();

                                          if (supportId ==
                                                  null ||
                                              supportId.isEmpty) {
                                            throw Exception(
                                              'Support request ID is missing.',
                                            );
                                          }

                                          final response =
                                              responseController
                                                  .text
                                                  .trim();

                                          await _dbService
                                              .updateSupportRequestStatus(
                                            supportId:
                                                supportId,
                                            status:
                                                selectedStatus,
                                            adminResponse:
                                                response.isEmpty
                                                    ? null
                                                    : response,
                                          );

                                          if (!mounted) {
                                            return;
                                          }

                                          Navigator.pop(
                                            sheetContext,
                                          );

                                          await _loadSupportRequests();

                                          if (!mounted) {
                                            return;
                                          }

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Support request updated successfully.',
                                              ),
                                              backgroundColor:
                                                  Colors.green,
                                            ),
                                          );
                                        } catch (e) {
                                          setSheetState(() {
                                            isSaving = false;
                                          });

                                          if (!mounted) {
                                            return;
                                          }

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to update request: '
                                                '${e.toString().replaceFirst('Exception: ', '')}',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFFFF5722),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Save Response',
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    responseController.dispose();
  }

  Widget _detailLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6B7280),
      ),
    );
  }

  Widget _categoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3EC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFF5722),
        ),
      ),
    );
  }

  String _formatDate(String value) {
    if (value.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(value);

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      final hour = date.hour == 0
          ? 12
          : date.hour > 12
              ? date.hour - 12
              : date.hour;

      final minute =
          date.minute.toString().padLeft(2, '0');

      final period = date.hour >= 12 ? 'PM' : 'AM';

      return '$day/$month/$year • $hour:$minute $period';
    } catch (_) {
      return value;
    }
  }
}

