import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/router/route_constants.dart';

import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';
import '../../../customers/domain/entities/invoice.dart';
import '../../../deals/presentation/bloc/deal_bloc.dart';
import '../../../deals/presentation/bloc/deal_event.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_event.dart';
import '../../../../core/services/receipt_service.dart';

import '../widgets/signature_pad.dart';
import '../widgets/payment_form.dart';
import '../widgets/stock_check_sheet.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart' as auth;
import '../../../auth/presentation/bloc/auth_state.dart' as auth;
import '../../../../core/di/injection.dart';

class CheckOutPage extends StatefulWidget {
  final String scheduleId;
  final String? taskDestinationId;
  final String? customerId;
  final String? leadId;
  final String? dealId;
  final List<Map<String, dynamic>>? dealItems;
  final Duration? duration;
  final String? activityNotes;
  final String? customerName;

  const CheckOutPage({
    super.key,
    required this.scheduleId,
    this.taskDestinationId,
    this.customerId,
    this.leadId,
    this.dealId,
    this.dealItems,
    this.duration,
    this.activityNotes,
    this.customerName,
  });

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  final _formKey = GlobalKey<FormState>();
  final _visitResultController = TextEditingController();
  final _priceOverrideController = TextEditingController();
  final _priceOverrideNoteController = TextEditingController();

  String? _selectedNextStep;
  final List<String> _nextStepOptions = [
    'Send Proposal',
    'Schedule Call',
    'Follow up Meeting',
    'Close Deal',
    'No Action Required'
  ];

  bool _isSubmitting = false;


  String? _selectedOutcome;
  final Map<String, String> _outcomeOptions = {
    'negotiation': 'Tahap Negosiasi',
    'deal_won': 'Tawaran Berhasil',
    'collection': 'Tagihan (Collection)',
    'deal_lost': 'Tawaran Ditolak',
    'follow_up': 'Perlu Follow Up',
  };

  // Specialized workflow state
  dynamic _signatureBytes;
  String? _paymentMethod;
  String? _paymentRef;
  String? _selectedInvoiceId;
  String? _selectedInvoiceNo;

  DateTime? _nextVisitDate;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  XFile? _receiptPhoto;
  final ImagePicker _picker = ImagePicker();

  static const Color _orange = Color(0xFFE8622A);
  static const Color _lightOrangeBg = Color(0xFFFFF7ED);
  static const Color _lightOrangeBorder = Color(0xFFFFEDD5);
  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF4B5563);

  @override
  void initState() {
    super.initState();
    _determinePosition();
    if (widget.activityNotes != null) {
      _visitResultController.text = widget.activityNotes!;
    }
    
    // Calculate total from dealItems and pre-fill price override if empty
    if (widget.dealItems != null && widget.dealItems!.isNotEmpty) {
      double total = 0;
      for (var item in widget.dealItems!) {
        total += (item['subtotal'] ?? 0).toDouble();
      }
      if (_priceOverrideController.text.isEmpty) {
        _priceOverrideController.text = total.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _visitResultController.dispose();
    _priceOverrideController.dispose();
    _priceOverrideNoteController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _orange,
              onPrimary: Colors.white,
              onSurface: _textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _nextVisitDate) {
      setState(() {
        _nextVisitDate = picked;
      });
    }
  }

  String? _mapResultToStage(String result, String? nextStep, {String? outcome}) {
    // 1. Prioritize explicit outcome selection
    if (outcome != null) {
      if (outcome == 'deal_won') return 'closed_won';
      if (outcome == 'deal_lost') return 'closed_lost';
      if (outcome == 'negotiation') return 'negotiation';
      if (outcome == 'follow_up') return 'qualification';
    }

    // 2. Fallback to manual text results or next steps
    final res = result.toLowerCase();
    
    if (nextStep == 'Close Deal') return 'closed_won';
    if (res.contains('po') || res.contains('submit') || res.contains('deal done')) return 'closed_won';
    if (res.contains('rejected') || res.contains('fail') || res.contains('lost')) return 'closed_lost';
    if (res.contains('negotiation') || res.contains('nego')) return 'negotiation';
    if (res.contains('sample') || res.contains('survey') || res.contains('eval')) return 'survey';
    
    return null;
  }
  Future<void> _takeReceiptPhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (photo != null) {
      setState(() {
        _receiptPhoto = photo;
      });
    }
  }
  void _submitCheckOut() {
    if (_isSubmitting) return;
    
    if (_formKey.currentState!.validate() && _currentPosition != null) {
      setState(() => _isSubmitting = true);
      
      String formattedDate = '';
      if (_nextVisitDate != null) {
        formattedDate = DateFormat('yyyy-MM-dd').format(_nextVisitDate!);
      }

      if (_selectedOutcome == 'deal_won' && _receiptPhoto == null) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bukti nota pembayaran wajib diunggah untuk Deal Won!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      context.read<VisitBloc>().add(
            CheckOutSubmitted(
              scheduleId: widget.scheduleId,
              latitude: _currentPosition!.latitude,
              longitude: _currentPosition!.longitude,
              visitResult: _visitResultController.text,
              nextAction: _selectedNextStep ?? '',
              nextVisitDate: formattedDate,
              taskDestinationId: widget.taskDestinationId,
              customerId: widget.customerId,
              leadId: widget.leadId,
              priceOverride: double.tryParse(_priceOverrideController.text),
              priceOverrideNote: _priceOverrideNoteController.text,
              dealId: widget.dealId,
              dealItems: widget.dealItems,
              outcome: _selectedOutcome,
              invoiceId: _selectedInvoiceId,
              signatureBytes: _signatureBytes,
              paymentMethod: _paymentMethod,
              paymentRef: _paymentRef,
              receiptPhotoFile: _receiptPhoto,
            ),
          );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: _textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Visit Check-Out',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: _orange),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade100, height: 1.0),
        ),
      ),
      body: BlocListener<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is VisitSuccess) {
            setState(() => _isSubmitting = false);
            debugPrint('VisitSuccess received! Message: ${state.message}');
            debugPrint('Task Completed Status: ${state.isTaskCompleted}');
            debugPrint('Task Destination ID: ${widget.taskDestinationId}');

            // ── Deal Pipeline Automation ──
            final dealIdToUpdate = widget.dealId ?? state.currentDealId;
            if (dealIdToUpdate != null) {
              final targetStage = _mapResultToStage(_visitResultController.text, _selectedNextStep, outcome: _selectedOutcome);
              if (targetStage != null) {
                context.read<DealBloc>().add(
                  UpdateDealStageSubmitted(
                    id: dealIdToUpdate,
                    stage: targetStage,
                  ),
                );
              } else {
                // If no stage transition, at least refresh the list to show the new deal
                context.read<DealBloc>().add(const FetchDeals());
              }
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: const Color(0xFF10B981)),
            );
            
            // Refresh tasks globally so maps and lists show updated status
            context.read<TaskBloc>().add(const FetchTasks());

            if (state.isTaskCompleted) {
              context.goNamed(kRouteTasks);
            } else {
              if (_selectedOutcome == 'deal_won' || _selectedOutcome == 'collection') {
                _showSuccessDialog(state.currentDealId ?? 'NEW');
              } else {
                context.pop(true);
              }
            }
          } else if (state is VisitError) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: const Color(0xFFEF4444)),
            );
          }
        },
        child: BlocBuilder<VisitBloc, VisitState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDurationCard(),
                          if (widget.dealItems != null && widget.dealItems!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildDealSummaryCard(),
                          ],
                          const SizedBox(height: 24),
                          _buildLabel('Visit Outcome'),
                          _buildOutcomeDropdown(),
                          const SizedBox(height: 20),
                          
                          // Specialized Contextual Widgets
                          _buildSpecializedWorkflowWidgets(state),
                          
                          const SizedBox(height: 20),
                          _buildLabel('Visit Notes / Remarks'),
                          _buildSummaryField(),
                          const SizedBox(height: 20),
                          if (widget.dealId != null || widget.taskDestinationId != null) ...[
                            _buildLabel('Price Adjustment (Optional)'),
                            _buildPriceOverrideFields(),
                            const SizedBox(height: 20),
                          ],
                          _buildLabel('Next Step'),
                          _buildNextStepDropdown(),
                          const SizedBox(height: 20),
                          _buildLabel('Follow-up Date'),
                          _buildDatePickerField(),
                          const SizedBox(height: 20),
                          _buildPhotoUploadField(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBottomSection(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDurationCard() {
    String durationStr = '0m';
    if (widget.duration != null) {
      final d = widget.duration!;
      if (d.inHours > 0) {
        durationStr = '${d.inHours}h ${d.inMinutes.remainder(60)}m';
      } else {
        durationStr = '${d.inMinutes}m';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: _lightOrangeBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _lightOrangeBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL VISIT DURATION',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.alarmClock, color: _orange, size: 28),
              const SizedBox(width: 12),
              Text(
                durationStr,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    double total = 0;
    if (widget.dealItems != null) {
      for (var item in widget.dealItems!) {
        total += (item['subtotal'] ?? 0).toDouble();
      }
    }
    return total;
  }

  Widget _buildDealSummaryCard() {
    final total = _calculateTotal();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.shoppingBag, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'DEAL SUMMARY',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.dealItems?.length ?? 0} Items',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rp ${NumberFormat('#,###', 'id_ID').format(total)}',
                style: const TextStyle(
                  color: _orange,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: _textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildOutcomeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedOutcome,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _orange),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      hint: const Text('Pilih Hasil Kunjungan', style: TextStyle(fontSize: 14)),
      items: _outcomeOptions.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedOutcome = value;
        });
      },
      validator: (value) => value == null ? 'Silakan pilih hasil kunjungan' : null,
    );
  }

  Widget _buildSummaryField() {
    return TextFormField(
      controller: _visitResultController,
      maxLines: 4,
      style: const TextStyle(fontSize: 14, color: _textPrimary),
      decoration: InputDecoration(
        hintText: 'Describe the meeting outcomes, pain points identified, and general sentiment...',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _orange),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Result is required';
        }
        return null;
      },
    );
  }

  Widget _buildNextStepDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedNextStep,
      icon: Icon(LucideIcons.chevronDown, color: Colors.grey.shade500, size: 20),
      style: const TextStyle(fontSize: 14, color: _textPrimary),
      decoration: InputDecoration(
        hintText: 'Select a follow-up action',
        hintStyle: const TextStyle(color: _textPrimary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _orange),
        ),
      ),
      items: _nextStepOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedNextStep = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Action is required';
        }
        return null;
      },
    );
  }

  Widget _buildDatePickerField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _nextVisitDate == null
                  ? 'mm/dd/yyyy'
                  : DateFormat('MM/dd/yyyy').format(_nextVisitDate!),
              style: TextStyle(
                fontSize: 14,
                color: _nextVisitDate == null ? _textPrimary.withOpacity(0.9) : _textPrimary,
              ),
            ),
            Icon(LucideIcons.calendar, color: Colors.grey.shade500, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUploadField() {
    return GestureDetector(
      onTap: _takeReceiptPhoto,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (_selectedOutcome == 'deal_won' && _receiptPhoto == null) ? Colors.red.shade300 : Colors.grey.shade300,
            width: 1.5,
            style: BorderStyle.solid, 
          ),
        ),
        child: _receiptPhoto != null 
          ? Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb
                      ? Image.network(
                          _receiptPhoto!.path,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(_receiptPhoto!.path),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tap untuk ganti foto nota',
                  style: TextStyle(color: _orange, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.camera, color: (_selectedOutcome == 'deal_won') ? Colors.red : Colors.grey.shade500, size: 20),
                const SizedBox(width: 12),
                Text(
                  _selectedOutcome == 'deal_won' ? 'Upload Bukti Nota (WAJIB)' : 'Add visit photos or document scans',
                  style: TextStyle(
                    color: (_selectedOutcome == 'deal_won') ? Colors.red : Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: _selectedOutcome == 'deal_won' ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildPriceOverrideFields() {
    return Column(
      children: [
        TextFormField(
          controller: _priceOverrideController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            hintText: 'New total amount...',
            prefixIcon: const Icon(LucideIcons.banknote, size: 18),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _orange)),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _priceOverrideNoteController,
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            hintText: 'Reason (e.g., Promo Bundle)',
            prefixIcon: const Icon(LucideIcons.stickyNote, size: 18),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _orange)),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecializedWorkflowWidgets(VisitState visitState) {
    final authState = context.read<auth.AuthBloc>().state;
    if (authState is! auth.Authenticated) return const SizedBox.shrink();
    final user = authState.user;
    final String salesType = (user.salesType ?? 'motoris').toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Task Order: Always require signature ──
        if (salesType == 'task_order') ...[
          _buildLabel('Digital Signature (Proof of Visit)'),
          const SizedBox(height: 8),
          SignaturePad(
            onChanged: (bytes) => setState(() => _signatureBytes = bytes),
          ),
          const SizedBox(height: 24),
        ],

        // ── Collection (Tagihan) Workflow ──
        if (_selectedOutcome == 'collection') ...[
          _buildLabel('Select Invoice to Collect'),
          const SizedBox(height: 8),
          if (visitState is VisitSuccess && visitState.invoices.isNotEmpty)
            DropdownButtonFormField<String>(
              value: _selectedInvoiceId,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _orange)),
              ),
              hint: const Text('Pilih Invoice Pelanggan', style: TextStyle(fontSize: 14)),
              items: visitState.invoices.map((inv) {
                return DropdownMenuItem<String>(
                  value: inv.id,
                  child: Text('${inv.invoiceNo} (Rp ${NumberFormat('#,###').format(inv.amount - inv.paidAmount)})', style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                   _selectedInvoiceId = val;
                   _selectedInvoiceNo = visitState.invoices.firstWhere((it) => it.id == val).invoiceNo;
                   // Pre-fill amount with remaining balance
                   final inv = visitState.invoices.firstWhere((it) => it.id == val);
                   _priceOverrideController.text = (inv.amount - inv.paidAmount).toStringAsFixed(0);
                });
              },
              validator: (v) => v == null ? 'Pilih invoice' : null,
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(LucideIcons.alertCircle, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Text('Tidak ada invoice belum lunas ditemukan.', style: TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ),
            ),
          const SizedBox(height: 20),
          _buildLabel('Payment Details'),
          PaymentForm(
            amount: double.tryParse(_priceOverrideController.text) ?? 0,
            onChanged: (method, ref) {
                setState(() {
                  _paymentMethod = method;
                  _paymentRef = ref;
                });
            },
          ),
          const SizedBox(height: 24),
          _buildLabel('Digital Signature (Customer Confirmation)'),
          const SizedBox(height: 8),
          SignaturePad(
            onChanged: (bytes) => setState(() => _signatureBytes = bytes),
          ),
          const SizedBox(height: 24),
        ],

        // ── Canvas & Motoris (Closed Won): Inventory, Payment & Signature ──
        if (salesType == 'canvas' || salesType == 'motoris') ...[
          if (_selectedOutcome == 'deal_won') ...[
            _buildLabel('Inventory & Payment Details'),
            const SizedBox(height: 12),
            _buildInventoryCheckButton(),
            const SizedBox(height: 16),
            PaymentForm(
              amount: _calculateTotal(),
              onChanged: (method, ref) {
                setState(() {
                  _paymentMethod = method;
                  _paymentRef = ref;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildLabel('Digital Signature (Customer Validation)'),
            const SizedBox(height: 8),
            SignaturePad(
              onChanged: (bytes) => setState(() => _signatureBytes = bytes),
            ),
            const SizedBox(height: 24),
          ] else ...[
             _buildInventoryCheckButton(),
             const SizedBox(height: 24),
          ]
        ],

        // ── Motoris (Regular Visit Banner) ──
        if (salesType == 'motoris' && _selectedOutcome != 'deal_won')
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.mapPin, color: Colors.blue, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Motoris Mode Active',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'GPS tolerance set to 300m for this visit.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInventoryCheckButton() {
    return InkWell(
      onTap: () {
        // Use existing StockCheckSheet or create a new one for Van Stock
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (context) => StockCheckSheet(onConfirm: (data) {}),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.package, color: _orange.withOpacity(0.6), size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Check Van Stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Ensure items are available in your vehicle', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<VisitBloc, VisitState>(
            builder: (context, state) {
              final isLoading = state is VisitLoading || _isLoadingLocation || _isSubmitting;
              final canSubmit = _currentPosition != null && !isLoading;


              return ElevatedButton(
                onPressed: canSubmit ? _submitCheckOut : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  disabledBackgroundColor: _orange.withOpacity(0.5),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Complete Visit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'WOWIN CR MOBILE V2.4.0',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String dealId) {
    bool isCollection = _selectedOutcome == 'collection';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Icon(isCollection ? LucideIcons.checkCircle : LucideIcons.partyPopper, color: _orange, size: 48),
            const SizedBox(height: 16),
            Text(isCollection ? 'TAGIHAN BERHASIL!' : 'DEAL BERHASIL!', style: const TextStyle(fontWeight: FontWeight.w900, color: _orange)),
          ],
        ),
        content: Text(
          isCollection 
            ? 'Pembayaran tagihan telah dicatat dan invoice telah diperbarui. Apakah Anda ingin mengunduh struk bukti bayar?'
            : 'Laporan kunjungan disimpan dan deal telah diproses. Apakah Anda ingin mengunduh struk sekarang?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('TIDAK, NANTI SAJA', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final receiptService = sl<ReceiptService>();
              await receiptService.generateAndShareReceipt(
                customerName: widget.customerName ?? 'Pelanggan',
                invoiceNo: isCollection ? (_selectedInvoiceNo ?? 'INV-COL') : 'INV-${dealId.substring(0, 8).toUpperCase()}',
                items: isCollection ? [] : (widget.dealItems ?? []),
                total: double.tryParse(_priceOverrideController.text) ?? 0,
                paymentMethod: _paymentMethod ?? 'CASH',
                paymentRef: _paymentRef,
                signatureBytes: _signatureBytes,
                isCollection: isCollection,
              );
              if (mounted) Navigator.pop(context, true);
            },
            icon: const Icon(LucideIcons.download, size: 18),
            label: const Text('UNDUH STRUK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) context.pop(true);
    });
  }
}

