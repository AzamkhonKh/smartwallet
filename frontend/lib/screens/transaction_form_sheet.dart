import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/app_snack_bar.dart';

class TransactionFormSheet extends StatefulWidget {
  final ApiService apiService;
  final Map<String, dynamic>? transaction;
  final Function(Map<String, dynamic>)? onSaved;

  const TransactionFormSheet({
    super.key,
    required this.apiService,
    this.transaction,
    this.onSaved,
  });

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _merchantController;
  late TextEditingController _addressController;
  late TextEditingController _amountController;

  List<dynamic> _accounts = [];
  List<String> _dbCategories = [];
  String? _selectedFromAccountId;
  String? _selectedToAccountId;
  bool _isTransfer = false;
  List<String> _selectedCategories = [];

  late String _selectedCurrency;
  late DateTime _selectedDateTime;
  bool _isLoading = false;
  List<Map<String, dynamic>> _items = [];

  bool get _isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    final tx = widget.transaction;
    _merchantController = TextEditingController(text: tx?['merchant'] ?? '');
    _addressController = TextEditingController(text: tx?['merchantAddress'] ?? '');

    final total = tx?['totalAmount'];
    _amountController = TextEditingController(text: total != null ? total.toString() : '0.00');

    _selectedCurrency = tx?['currency'] ?? 'USD';
    _selectedFromAccountId = tx?['fromAccountId'];
    _selectedToAccountId = tx?['toAccountId'];
    _isTransfer = tx?['toAccountId'] != null;
    _selectedCategories = List<String>.from(tx?['categories'] ?? []);

    if (tx?['transactionDate'] != null) {
      try {
        _selectedDateTime = DateTime.parse(tx!['transactionDate']);
      } catch (_) {
        _selectedDateTime = DateTime.now();
      }
    } else {
      _selectedDateTime = DateTime.now();
    }

    if (tx != null && tx['items'] != null) {
      for (var item in tx['items']) {
        final Map<String, dynamic> itemMap = {
          'id': item['id'],
          'nameController': TextEditingController(text: item['name']?.toString() ?? ''),
          'priceController': TextEditingController(text: item['price']?.toString() ?? '0.00'),
          'qtyController': TextEditingController(text: item['qty']?.toString() ?? '1'),
        };
        _addItemListeners(itemMap);
        _items.add(itemMap);
      }
    }

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final accs = await widget.apiService.getAccounts();
      final cats = await widget.apiService.getCategories();
      setState(() {
        _accounts = accs;
        _dbCategories = List<String>.from(cats);

        if (!_isEditMode && _accounts.isNotEmpty) {
          _selectedFromAccountId = _accounts.first['id'];
          _selectedCurrency = _accounts.first['currency'] ?? 'USD';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) AppSnackBar.fromException(context, e);
    }
  }

  void _addItemListeners(Map<String, dynamic> item) {
    item['priceController'].addListener(_recalculateTotalFromItems);
    item['qtyController'].addListener(_recalculateTotalFromItems);
  }

  void _recalculateTotalFromItems() {
    double total = 0.0;
    for (var item in _items) {
      final price = double.tryParse(item['priceController'].text) ?? 0.0;
      final qty = int.tryParse(item['qtyController'].text) ?? 1;
      total += price * qty;
    }
    if (total > 0) {
      _amountController.text = total.toStringAsFixed(2);
    }
  }

  void _addNewItem() {
    setState(() {
      final Map<String, dynamic> itemMap = {
        'id': null,
        'nameController': TextEditingController(text: ''),
        'priceController': TextEditingController(text: '0.00'),
        'qtyController': TextEditingController(text: '1'),
      };
      _addItemListeners(itemMap);
      _items.add(itemMap);
      _recalculateTotalFromItems();
    });
  }

  void _removeItem(int index) {
    setState(() {
      final item = _items.removeAt(index);
      item['priceController'].dispose();
      item['qtyController'].dispose();
      item['nameController'].dispose();
      _recalculateTotalFromItems();
    });
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _addressController.dispose();
    _amountController.dispose();
    for (var item in _items) {
      item['nameController'].dispose();
      item['priceController'].dispose();
      item['qtyController'].dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Color(0xFF101424),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0A0E1A),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF6C63FF),
                onPrimary: Colors.white,
                surface: Color(0xFF101424),
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: const Color(0xFF0A0E1A),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final itemsPayload = _items.map((item) {
      return {
        if (item['id'] != null) 'id': item['id'],
        'name': item['nameController'].text.trim(),
        'price': double.tryParse(item['priceController'].text.trim()) ?? 0.0,
        'qty': int.tryParse(item['qtyController'].text.trim()) ?? 1,
      };
    }).toList();

    final data = {
      'merchant': _merchantController.text.trim(),
      'merchantAddress': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      'totalAmount': double.parse(_amountController.text.trim()),
      'categories': _selectedCategories,
      'currency': _selectedCurrency,
      'transactionDate': _selectedDateTime.toIso8601String().split('.').first,
      'fromAccountId': _selectedFromAccountId,
      'toAccountId': _isTransfer ? _selectedToAccountId : null,
      'isDraft': false,
      'items': itemsPayload,
    };

    try {
      Map<String, dynamic> result;
      if (_isEditMode) {
        final id = widget.transaction!['id'] as int;
        result = await widget.apiService.updateTransaction(id, data);
      } else {
        result = await widget.apiService.createManualTransaction(data);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (widget.onSaved != null) {
          widget.onSaved!(result);
        }
        Navigator.pop(context, result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackBar.fromException(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF101424),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditMode ? 'Edit Transaction' : 'Add Transaction',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white38),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Merchant Field
              TextFormField(
                controller: _merchantController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Merchant Name/Payee', Icons.storefront_rounded),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter the merchant name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Source Account (From) Dropdown
              if (_accounts.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  value: _selectedFromAccountId,
                  dropdownColor: const Color(0xFF101424),
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration('Source Account', Icons.account_balance_wallet_rounded),
                  items: _accounts.map((acc) {
                    return DropdownMenuItem<String>(
                      value: acc['id'] as String,
                      child: Text('${acc['name']} (${acc['currency']})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedFromAccountId = val;
                        final acc = _accounts.firstWhere((element) => element['id'] == val);
                        _selectedCurrency = acc['currency'] ?? 'USD';
                      });
                    }
                  },
                  validator: (val) => val == null ? 'Source account is required' : null,
                ),
                const SizedBox(height: 16),

                // Transfer Toggle Switch
                SwitchListTile(
                  title: Text(
                    'Is this a transfer to another account?',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                  ),
                  value: _isTransfer,
                  activeColor: const Color(0xFF6C63FF),
                  onChanged: (val) {
                    setState(() {
                      _isTransfer = val;
                      if (!val) {
                        _selectedToAccountId = null;
                      } else if (_selectedToAccountId == null && _accounts.length > 1) {
                        final otherAccs = _accounts.where((acc) => acc['id'] != _selectedFromAccountId).toList();
                        if (otherAccs.isNotEmpty) {
                          _selectedToAccountId = otherAccs.first['id'];
                        }
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Destination Account (To) Dropdown
                if (_isTransfer) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedToAccountId,
                    dropdownColor: const Color(0xFF101424),
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Destination Account', Icons.swap_horiz_rounded),
                    items: _accounts.where((acc) => acc['id'] != _selectedFromAccountId).map((acc) {
                      return DropdownMenuItem<String>(
                        value: acc['id'] as String,
                        child: Text('${acc['name']} (${acc['currency']})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedToAccountId = val;
                      });
                    },
                    validator: (val) {
                      if (_isTransfer && val == null) {
                        return 'Destination account is required for transfers';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ],

              // Currency Field
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                dropdownColor: const Color(0xFF101424),
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Transaction Currency', Icons.currency_exchange_rounded),
                items: ['USD', 'EUR', 'GBP', 'UZS'].map((curr) {
                  return DropdownMenuItem<String>(
                    value: curr,
                    child: Text(curr, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCurrency = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Total Amount', Icons.attach_money_rounded),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter the amount';
                  }
                  final amount = double.tryParse(val.trim());
                  if (amount == null || amount < 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address Field (Optional)
              TextFormField(
                controller: _addressController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Merchant Address (Optional)', Icons.pin_drop_outlined),
              ),
              const SizedBox(height: 24),

              // Category Selector Header
              Text(
                'CATEGORIES (SELECT MULTIPLE TAGS)',
                style: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),

              // Category Selection Chips
              if (_dbCategories.isEmpty)
                Text(
                  'No categories available. Please add some in the Categories tab.',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _dbCategories.map((name) {
                    final isSelected = _selectedCategories.contains(name);

                    return ChoiceChip(
                      label: Text(name),
                      selected: isSelected,
                      labelStyle: GoogleFonts.inter(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      backgroundColor: Colors.white.withOpacity(0.02),
                      selectedColor: const Color(0xFF6C63FF).withOpacity(0.8),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.08),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(name);
                          } else {
                            _selectedCategories.remove(name);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

              // Line Items Section
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LINE ITEMS',
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF00D2FF),
                    ),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                    label: const Text('Add Item'),
                    onPressed: _addNewItem,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No items added yet. Click Add Item to enter products.',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.01),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.04)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  controller: item['nameController'],
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: const InputDecoration(
                                    labelText: 'Item Name',
                                    labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
                                    isDense: true,
                                    border: InputBorder.none,
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Enter item name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFC70039), size: 20),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: item['priceController'],
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: const InputDecoration(
                                    labelText: 'Price',
                                    labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
                                    isDense: true,
                                    border: InputBorder.none,
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(val) == null) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: item['qtyController'],
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: const InputDecoration(
                                    labelText: 'Quantity',
                                    labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
                                    isDense: true,
                                    border: InputBorder.none,
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    if (int.tryParse(val) == null) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),

              // Date/Time Selector Row
              Text(
                'TRANSACTION DATE & TIME',
                style: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: Color(0xFF6C63FF), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _formatDateTime(_selectedDateTime),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down_rounded, color: Colors.white38),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)],
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _submitForm,
                        child: Text(
                          _isEditMode ? 'Save Edits' : 'Save Transaction',
                          style: GoogleFonts.inter(
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
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white38, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.02),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      errorStyle: const TextStyle(color: Color(0xFFC70039)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFC70039)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFC70039), width: 1.5),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final year = dt.year;
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }
}
