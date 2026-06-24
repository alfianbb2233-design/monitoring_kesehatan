import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/health_record.dart';
import '../providers/health_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class EditHealthScreen extends StatefulWidget {
  final HealthRecord record;

  const EditHealthScreen({super.key, required this.record});

  @override
  State<EditHealthScreen> createState() => _EditHealthScreenState();
}

class _EditHealthScreenState extends State<EditHealthScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _bloodPressureController;
  late final TextEditingController _heartRateController;
  late final TextEditingController _notesController;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.tryParse(widget.record.date) ?? DateTime.now();
    _weightController =
        TextEditingController(text: widget.record.weight.toString());
    _heightController =
        TextEditingController(text: widget.record.height.toString());
    _bloodPressureController =
        TextEditingController(text: widget.record.bloodPressure);
    _heartRateController =
        TextEditingController(text: widget.record.heartRate.toString());
    _notesController = TextEditingController(text: widget.record.notes);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _bloodPressureController.dispose();
    _heartRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _updateRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final updatedRecord = widget.record.copyWith(
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      weight: double.parse(_weightController.text),
      height: double.parse(_heightController.text),
      bloodPressure: _bloodPressureController.text.trim(),
      heartRate: int.parse(_heartRateController.text),
      notes: _notesController.text.trim(),
    );

    await context.read<HealthProvider>().updateRecord(updatedRecord);
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data kesehatan berhasil diperbarui')),
    );
    Navigator.pop(context, updatedRecord);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Data')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              boxShadow: AppTheme.softShadow(context),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Perbarui Informasi',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 18),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal',
                        prefixIcon: Icon(Icons.calendar_month_rounded),
                      ),
                      child: Text(DateFormat('dd MMMM yyyy', 'id_ID')
                          .format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _NumberField(
                    controller: _weightController,
                    label: 'Berat Badan (kg)',
                    icon: Icons.monitor_weight_rounded,
                    allowDecimal: true,
                  ),
                  const SizedBox(height: 16),
                  _NumberField(
                    controller: _heightController,
                    label: 'Tinggi Badan (cm)',
                    icon: Icons.height_rounded,
                    allowDecimal: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bloodPressureController,
                    decoration: const InputDecoration(
                      labelText: 'Tekanan Darah',
                      hintText: 'Contoh: 120/80',
                      prefixIcon: Icon(Icons.bloodtype_rounded),
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  _NumberField(
                    controller: _heartRateController,
                    label: 'Detak Jantung',
                    icon: Icons.favorite_rounded,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Kesehatan',
                      prefixIcon: Icon(Icons.notes_rounded),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'Simpan Perubahan',
                    icon: Icons.save_rounded,
                    isLoading: _isSaving,
                    onPressed: _updateRecord,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool allowDecimal;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.icon,
    this.allowDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return 'Field ini wajib diisi';
        final number = num.tryParse(text);
        if (number == null || number <= 0) return 'Masukkan angka yang valid';
        return null;
      },
    );
  }
}

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Field ini wajib diisi';
  return null;
}
