import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';

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
      ),
      body: BlocListener<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is VisitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            context.pop(); // Route back
          } else if (state is VisitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Theme.of(context).colorScheme.error),
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
                  const Center(child: CircularProgressIndicator())
                else if (_locationError != null)
                  Text(_locationError!, style: TextStyle(color: Theme.of(context).colorScheme.error))
                else if (_currentPosition != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Lokasi didapatkan: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Form Fields
                TextFormField(
                  controller: _visitResultController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Hasil Kunjungan (Wajib)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
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
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Jadwal Kunjungan Berikutnya'),
                  subtitle: Text(
                    _nextVisitDate == null 
                      ? 'Belum diatur' 
                      : DateFormat('dd MMM yyyy').format(_nextVisitDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
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
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('SUBMIT CHECK-OUT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
