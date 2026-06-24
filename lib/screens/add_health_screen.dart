import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/health_record.dart';
import '../providers/health_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class AddHealthScreen extends StatefulWidget {
  const AddHealthScreen({super.key});

  @override
  State<AddHealthScreen> createState() => _AddHealthScreenState();
}

class _AddHealthScreenState extends State<AddHealthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

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

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final record = HealthRecord(
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      weight: double.parse(_weightController.text),
      height: double.parse(_heightController.text),
      bloodPressure: _bloodPressureController.text.trim(),
      heartRate: int.parse(_heartRateController.text),
      notes: _notesController.text.trim(),
    );

    await context.read<HealthProvider>().addRecord(record);
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data kesehatan berhasil disimpan')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Data')),
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
            child: _HealthForm(
              formKey: _formKey,
              selectedDate: _selectedDate,
              onPickDate: _pickDate,
              weightController: _weightController,
              heightController: _heightController,
              bloodPressureController: _bloodPressureController,
              heartRateController: _heartRateController,
              notesController: _notesController,
              buttonLabel: 'Simpan Data',
              isSaving: _isSaving,
              onSubmit: _saveRecord,
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final DateTime selectedDate;
  final VoidCallback onPickDate;
  final TextEditingController weightController;
  final TextEditingController heightController;
  final TextEditingController bloodPressureController;
  final TextEditingController heartRateController;
  final TextEditingController notesController;
  final String buttonLabel;
  final bool isSaving;
  final VoidCallback onSubmit;

  const _HealthForm({
    required this.formKey,
    required this.selectedDate,
    required this.onPickDate,
    required this.weightController,
    required this.heightController,
    required this.bloodPressureController,
    required this.heartRateController,
    required this.notesController,
    required this.buttonLabel,
    required this.isSaving,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Kesehatan',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: onPickDate,
            borderRadius: BorderRadius.circular(16),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Tanggal',
                prefixIcon: Icon(Icons.calendar_month_rounded),
              ),
              child: Text(formattedDate),
            ),
          ),
          const SizedBox(height: 16),
          _NumberField(
            controller: weightController,
            label: 'Berat Badan (kg)',
            icon: Icons.monitor_weight_rounded,
            allowDecimal: true,
          ),
          const SizedBox(height: 16),
          _NumberField(
            controller: heightController,
            label: 'Tinggi Badan (cm)',
            icon: Icons.height_rounded,
            allowDecimal: true,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: bloodPressureController,
            decoration: const InputDecoration(
              labelText: 'Tekanan Darah',
              hintText: 'Contoh: 120/80',
              prefixIcon: Icon(Icons.bloodtype_rounded),
            ),
            validator: _requiredValidator,
          ),
          const SizedBox(height: 16),
          _NumberField(
            controller: heartRateController,
            label: 'Detak Jantung',
            icon: Icons.favorite_rounded,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: notesController,
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
            label: buttonLabel,
            icon: Icons.save_rounded,
            isLoading: isSaving,
            onPressed: onSubmit,
          ),
        ],
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
