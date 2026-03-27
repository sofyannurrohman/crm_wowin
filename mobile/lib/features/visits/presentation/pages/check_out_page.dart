import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';
import '../../../../core/theme/app_colors.dart';

class CheckOutPage extends StatefulWidget {
  final String scheduleId;

  const CheckOutPage({super.key, required this.scheduleId});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  final _formKey = GlobalKey<FormState>();
  final _visitResultController = TextEditingController();
  final _nextActionController = TextEditingController();

  DateTime? _nextVisitDate;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _visitResultController.dispose();
    _nextActionController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _locationError = e.toString();
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _nextVisitDate) {
      setState(() {
        _nextVisitDate = picked;
      });
    }
  }

  void _submitCheckOut() {
    if (_formKey.currentState!.validate() && _currentPosition != null) {
      String formattedDate = '';
      if (_nextVisitDate != null) {
        formattedDate = DateFormat('yyyy-MM-dd').format(_nextVisitDate!);
      }

      context.read<VisitBloc>().add(
            CheckOutSubmitted(
              scheduleId: widget.scheduleId,
              latitude: _currentPosition!.latitude,
              longitude: _currentPosition!.longitude,
              visitResult: _visitResultController.text,
              nextAction: _nextActionController.text,
              nextVisitDate: formattedDate,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-Out Kunjungan'),
        scrolledUnderElevation: 0,
      ),
      body: BlocListener<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is VisitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
            context.pop(); // Route back
          } else if (state is VisitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Location Status
                if (_isLoadingLocation)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_locationError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(_locationError!,
                        style: const TextStyle(color: AppColors.error)),
                  )
                else if (_currentPosition != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColors.success.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person,
                            color: AppColors.success, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lokasi Berhasil Didapatkan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Form Fields
                TextFormField(
                  controller: _visitResultController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Hasil Kunjungan (Wajib)',
                    alignLabelWithHint: true,
                    hintText: 'Tuliskan hasil kunjungan di sini...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Hasil kunjungan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nextActionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Tindakan Selanjutya (Opsional)',
                    alignLabelWithHint: true,
                    hintText: 'Tindakan apa yang perlu dilakukan setelah ini?',
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: const Text(
                      'Jadwal Kunjungan Berikutnya',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      _nextVisitDate == null
                          ? 'Klik untuk mengatur jadwal'
                          : DateFormat('dd MMMM yyyy').format(_nextVisitDate!),
                      style: TextStyle(
                        color: _nextVisitDate == null
                            ? Colors.grey
                            : AppColors.primary,
                        fontWeight: _nextVisitDate == null
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.person,
                        size: 20, color: AppColors.primary),
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                BlocBuilder<VisitBloc, VisitState>(
                  builder: (context, state) {
                    final isLoading = state is VisitLoading;
                    final canSubmit = _currentPosition != null && !isLoading;

                    return ElevatedButton(
                      onPressed: canSubmit ? _submitCheckOut : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'SUBMIT CHECK-OUT',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
