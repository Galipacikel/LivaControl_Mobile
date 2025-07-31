import 'package:flutter/material.dart';
import 'add_expense3.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/expense_report.dart';
import 'package:flutter/services.dart';

class AddExpense2Page extends StatefulWidget {
  final String reportName;
  final ExpenseReport? existingReport;
  final Map<String, dynamic>? editingExpense;
  const AddExpense2Page({
    super.key,
    required this.reportName,
    this.existingReport,
    this.editingExpense,
  });

  @override
  State<AddExpense2Page> createState() => _AddExpense2PageState();
}

class _AddExpense2PageState extends State<AddExpense2Page> {
  final TextEditingController _vendorController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _vatController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;
  List<String> mockCategories = ['Yemek', 'Ulaşım', 'Konaklama', 'Ofis'];
  File? _image;

  // Gider listesi ve toplam değer
  List<Map<String, dynamic>> _expenses = [];
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.editingExpense != null) {
      final exp = widget.editingExpense!;
      _vendorController.text = exp['vendor']?.toString() ?? '';
      _amountController.text = exp['amount']?.toString() ?? '';
      _descController.text = exp['desc']?.toString() ?? '';
      _selectedDate = exp['date'];
      _selectedCategory = exp['category']?.toString();
    } else if (widget.existingReport != null) {
      _expenses = List<Map<String, dynamic>>.from(
        widget.existingReport!.expenses,
      );
      _totalAmount = widget.existingReport!.totalAmount;
      if (_expenses.isNotEmpty) {
        final exp = _expenses.last;
        _vendorController.text = exp['vendor']?.toString() ?? '';
        _amountController.text = exp['amount']?.toString() ?? '';
        _descController.text = exp['desc']?.toString() ?? '';
        _selectedDate = exp['date'];
        _selectedCategory = exp['category']?.toString();
      }
    }
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _amountController.dispose();
    _descController.dispose();
    _vatController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      locale: const Locale('tr'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFF57A20)),
              title: const Text('Kamera'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo, color: Color(0xFFF57A20)),
              title: const Text('Galeriden Seç'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final inputFontSize = size.width < 350 ? 12.0 : 14.0;
    final inputVertical = size.height * 0.018 < 12 ? 12.0 : size.height * 0.018;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Gider Ekle',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rapor Adı (değiştirilemez)
              Text(
                ' Gider Kayıt Adı',
                style: TextStyle(
                  fontSize: inputFontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.reportName,
                  style: TextStyle(
                    fontSize: inputFontSize,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Resim yükle alanı
              Text(
                'Resim Yükle',
                style: TextStyle(
                  fontSize: inputFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerModal,
                      child: Container(
                        width: 64,
                        height: 64,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                  width: 64,
                                  height: 64,
                                ),
                              )
                            : const Icon(
                                Icons.add_a_photo,
                                color: Color(0xFFF57A20),
                                size: 32,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Satıcı Adı
              _LabeledInput(
                label: 'Satıcı Adı',
                controller: _vendorController,
                hintText: 'Satıcı adı giriniz',
                inputFontSize: inputFontSize,
                inputVertical: inputVertical,
              ),
              const SizedBox(height: 16),
              // Değer
              _LabeledInput(
                label: 'Değer',
                controller: _amountController,
                hintText: 'Tutar',
                inputFontSize: inputFontSize,
                inputVertical: inputVertical,
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 4),
                  child: Text(
                    'GBP',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: inputFontSize,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              // Tarih
              Text(
                'Tarih',
                style: TextStyle(
                  fontSize: inputFontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Tarih seçiniz'
                            : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                        style: TextStyle(
                          fontSize: inputFontSize,
                          color: _selectedDate == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFFF57A20),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Açıklama
              _LabeledInput(
                label: 'Açıklama',
                controller: _descController,
                hintText: 'Açıklama giriniz',
                inputFontSize: inputFontSize,
                inputVertical: inputVertical,
              ),
              const SizedBox(height: 16),
              // Kategori
              Text(
                'Kategori',
                style: TextStyle(
                  fontSize: inputFontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    hint: const Text('Kategori seçiniz'),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: mockCategories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(fontSize: inputFontSize),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Gider Ekle Butonu
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_vendorController.text.isEmpty ||
                            _amountController.text.isEmpty ||
                            _selectedDate == null) {
                          return;
                        }
                        final amount =
                            num.tryParse(_amountController.text)?.toDouble() ??
                            0.0;
                        final expense = {
                          'vendor': _vendorController.text,
                          'amount': amount,
                          'date': _selectedDate,
                          'desc': _descController.text,
                          'category': _selectedCategory,
                          'imagePath': _image?.path,
                        };
                        Navigator.of(context).pop(expense);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF57A20),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Gider Ekle'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _LabeledInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final double inputFontSize;
  final double inputVertical;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const _LabeledInput({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.inputFontSize,
    required this.inputVertical,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: inputFontSize,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: inputFontSize),
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: inputVertical,
              ),
              prefix: prefix,
              suffix: suffix,
            ),
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
          ),
        ),
      ],
    );
  }
}
