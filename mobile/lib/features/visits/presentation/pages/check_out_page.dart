import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
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
import '../../../../core/utils/image_utils.dart';

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
  final String? notaPhotoPath;

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
    this.notaPhotoPath,
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
    'negotiation': 'Negotiation Stage',
    'deal_won': 'Deal Secured / Success',
    'collection': 'Collection / Payment',
    'deal_lost': 'Proposal Declined',
    'follow_up': 'Follow-Up Required',
  };

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

  @override
  void initState() {
    super.initState();
    _determinePosition();
    if (widget.activityNotes != null) {
      _visitResultController.text = widget.activityNotes!;
    }
    if (widget.notaPhotoPath != null) {
      _receiptPhoto = XFile(widget.notaPhotoPath!);
    }
    
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
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _nextVisitDate) {
      setState(() => _nextVisitDate = picked);
    }
  }

  String? _mapResultToStage(String result, String? nextStep, {String? outcome}) {
    if (outcome != null) {
      if (outcome == 'deal_won') return 'closed_won';
      if (outcome == 'deal_lost') return 'closed_lost';
      if (outcome == 'negotiation') return 'negotiation';
      if (outcome == 'follow_up') return 'qualification';
    }
    final res = result.toLowerCase();
    if (nextStep == 'Close Deal') return 'closed_won';
    if (res.contains('po') || res.contains('submit') || res.contains('deal done')) return 'closed_won';
    if (res.contains('rejected') || res.contains('fail') || res.contains('lost')) return 'closed_lost';
    if (res.contains('negotiation') || res.contains('nego')) return 'negotiation';
    if (res.contains('sample') || res.contains('survey') || res.contains('eval')) return 'survey';
    return null;
  }

  Future<void> _takeReceiptPhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      // Preprocessing (Important for older devices/HP Lawas)
      // This resizes to max width 1024px and compresses to save bandwidth
      final File processedFile = await ImageUtils.processImageForUpload(File(photo.path));
      setState(() => _receiptPhoto = XFile(processedFile.path));
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
          const SnackBar(content: Text('Payment receipt photo is required for Deal Won!'), backgroundColor: Color(0xFFEF4444), behavior: SnackBarBehavior.floating),
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
      backgroundColor: AppColors.background,
      body: BlocListener<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is VisitSuccess) {
            setState(() => _isSubmitting = false);
            final dealIdToUpdate = widget.dealId ?? state.currentDealId;
            if (dealIdToUpdate != null) {
              final targetStage = _mapResultToStage(_visitResultController.text, _selectedNextStep, outcome: _selectedOutcome);
              if (targetStage != null) {
                context.read<DealBloc>().add(UpdateDealStageSubmitted(id: dealIdToUpdate, stage: targetStage));
              } else {
                context.read<DealBloc>().add(const FetchDeals());
              }
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Visit report saved successfully.'), backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating),
            );
            
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
              SnackBar(content: Text(state.message), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating),
            );
          }
        },
        child: BlocBuilder<VisitBloc, VisitState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildPremiumHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
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
                          const SizedBox(height: 32),
                          _buildSectionTitle('FINAL OUTCOME'),
                          const SizedBox(height: 12),
                          _buildOutcomeDropdown(),
                          const SizedBox(height: 24),
                          
                          _buildSpecializedWorkflowWidgets(state),
                          
                          const SizedBox(height: 24),
                          _buildSectionTitle('VISIT NOTES (OPTIONAL)'),
                          const SizedBox(height: 12),
                          _buildSummaryField(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('RECEIPT PHOTO'),
                          const SizedBox(height: 12),
                          _buildPhotoUploadField(),
                          const SizedBox(height: 32),

                          Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
                              child: ExpansionTile(
                                title: const Text('ADVANCED OPTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 0.5)),
                                tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                                childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                children: [
                                  if (widget.dealId != null || widget.taskDestinationId != null) ...[
                                    _buildSectionTitle('PRICE ADJUSTMENT'),
                                    const SizedBox(height: 12),
                                    _buildPriceOverrideFields(),
                                    const SizedBox(height: 24),
                                  ],
                                  _buildSectionTitle('NEXT FOLLOW-UP ACTION'),
                                  const SizedBox(height: 12),
                                  _buildNextStepDropdown(),
                                  const SizedBox(height: 24),
                                  _buildSectionTitle('NEXT VISIT DATE'),
                                  const SizedBox(height: 12),
                                  _buildDatePickerField(),
                                ],
                              ),
                            ),
                          ),
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

  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                  ),
                  const Text(
                    'Checkout Session',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 48), // Placeholder to center title
                ],
              ),
              const SizedBox(height: 24),
              Text(
                widget.customerName ?? 'Finalizing Visit',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  'End of visit summary & verification',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('VISIT DURATION', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(LucideIcons.timer, color: Color(0xFF34D399), size: 28),
              ),
              const SizedBox(width: 20),
              Text(
                durationStr,
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
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
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(LucideIcons.shoppingBag, color: Color(0xFF3B82F6), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TRANSACTION TOTAL', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(total)}',
                  style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text('${widget.dealItems?.length ?? 0} Items', style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 11, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPlaceholder, fontSize: 10, letterSpacing: 1.2));
  }

  Widget _buildOutcomeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedOutcome,
      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
      hint: const Text('Select final outcome', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPlaceholder)),
      items: _outcomeOptions.entries.map((entry) {
        return DropdownMenuItem<String>(value: entry.key, child: Text(entry.value));
      }).toList(),
      onChanged: (value) => setState(() => _selectedOutcome = value),
      validator: (value) => value == null ? 'Selection required' : null,
    );
  }

  Widget _buildSummaryField() {
    return TextFormField(
      controller: _visitResultController,
      maxLines: 4,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Record key discussion points or challenges...',
        hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }

  Widget _buildNextStepDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedNextStep,
      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)),
      ),
      items: _nextStepOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
      onChanged: (v) => setState(() => _selectedNextStep = v),
    );
  }

  Widget _buildDatePickerField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _nextVisitDate == null ? 'Pick follow-up date' : DateFormat('MMMM dd, yyyy').format(_nextVisitDate!),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _nextVisitDate == null ? AppColors.textPlaceholder : AppColors.textPrimary),
            ),
            const Icon(LucideIcons.calendar, color: AppColors.primary, size: 20),
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
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: (_selectedOutcome == 'deal_won' && _receiptPhoto == null) ? const Color(0xFFFCA5A5) : const Color(0xFFF1F5F9), width: 2, style: BorderStyle.solid),
        ),
        child: _receiptPhoto != null 
          ? Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: kIsWeb
                      ? Image.network(_receiptPhoto!.path, height: 180, width: 250, fit: BoxFit.cover)
                      : Image.file(File(_receiptPhoto!.path), height: 180, width: 250, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                const Text('REPLACE PHOTO', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ],
            )
          : Column(
              children: [
                Icon(LucideIcons.camera, color: (_selectedOutcome == 'deal_won') ? const Color(0xFFEF4444) : AppColors.textPlaceholder, size: 32),
                const SizedBox(height: 12),
                Text(
                  _selectedOutcome == 'deal_won' ? 'UPLOAD RECEIPT (REQUIRED)' : 'Capture session documentation',
                  style: TextStyle(color: (_selectedOutcome == 'deal_won') ? const Color(0xFFEF4444) : AppColors.textPlaceholder, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildPriceOverrideFields() {
    return Column(
      children: [
        _buildTextField(_priceOverrideController, 'Adjusted Total Amount', LucideIcons.banknote, keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        _buildTextField(_priceOverrideNoteController, 'Adjustment Reason', LucideIcons.fileText),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textPlaceholder),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)),
      ),
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
        if (salesType == 'task_order') ...[
          _buildSectionTitle('SIGNATURE (PROOF OF VISIT)'),
          const SizedBox(height: 12),
          SignaturePad(onChanged: (bytes) => setState(() => _signatureBytes = bytes)),
          const SizedBox(height: 32),
        ],

        if (_selectedOutcome == 'collection') ...[
          _buildSectionTitle('SELECT INVOICE'),
          const SizedBox(height: 12),
          if (visitState is VisitSuccess && visitState.invoices.isNotEmpty)
            DropdownButtonFormField<String>(
              value: _selectedInvoiceId,
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(20),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),
              hint: const Text('Pick Invoice', style: TextStyle(fontSize: 14)),
              items: visitState.invoices.map((inv) {
                return DropdownMenuItem<String>(
                  value: inv.id,
                  child: Text('${inv.invoiceNo} (Rp ${NumberFormat('#,###', 'id_ID').format(inv.amount - inv.paidAmount)})'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                   _selectedInvoiceId = val;
                   _selectedInvoiceNo = visitState.invoices.firstWhere((it) => it.id == val).invoiceNo;
                   final inv = visitState.invoices.firstWhere((it) => it.id == val);
                   _priceOverrideController.text = (inv.amount - inv.paidAmount).toStringAsFixed(0);
                });
              },
              validator: (v) => v == null ? 'Required' : null,
            )
          else
            _buildErrorBanner('No unpaid invoices found for this customer.'),
          const SizedBox(height: 24),
          _buildSectionTitle('PAYMENT DETAILS'),
          const SizedBox(height: 12),
          PaymentForm(
            amount: double.tryParse(_priceOverrideController.text) ?? 0,
            onChanged: (method, ref) => setState(() { _paymentMethod = method; _paymentRef = ref; }),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('SIGNATURE (CONFIRMATION)'),
          const SizedBox(height: 12),
          SignaturePad(onChanged: (bytes) => setState(() => _signatureBytes = bytes)),
          const SizedBox(height: 32),
        ],

        if (salesType == 'canvas' || salesType == 'motoris') ...[
          if (_selectedOutcome == 'deal_won') ...[
            _buildSectionTitle('INVENTORY & PAYMENT'),
            const SizedBox(height: 12),
            _buildInventoryCheckButton(),
            const SizedBox(height: 16),
            PaymentForm(
              amount: _calculateTotal(),
              onChanged: (method, ref) => setState(() { _paymentMethod = method; _paymentRef = ref; }),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('SIGNATURE (VALIDATION)'),
            const SizedBox(height: 12),
            SignaturePad(onChanged: (bytes) => setState(() => _signatureBytes = bytes)),
            const SizedBox(height: 32),
          ] else ...[
             _buildInventoryCheckButton(),
             const SizedBox(height: 24),
          ]
        ],

        if (salesType == 'motoris' && _selectedOutcome != 'deal_won')
          _buildInfoBanner('Motoris mode active. GPS verification is optimized for speed.'),
      ],
    );
  }

  Widget _buildErrorBanner(String msg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFECACA))),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(msg, style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(String msg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFBAE6FD))),
      child: Row(
        children: [
          const Icon(LucideIcons.info, color: Color(0xFF0EA5E9), size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(msg, style: const TextStyle(color: Color(0xFF0369A1), fontSize: 13, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Widget _buildInventoryCheckButton() {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => StockCheckSheet(onConfirm: (data) {}),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF1F5F9))),
        child: const Row(
          children: [
            Icon(LucideIcons.package, color: AppColors.primary, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verify Van Stock', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  Text('Ensure items are available in your vehicle', style: TextStyle(color: AppColors.textPlaceholder, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textPlaceholder),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFF1F5F9))),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: BlocBuilder<VisitBloc, VisitState>(
        builder: (context, state) {
          final isLoading = state is VisitLoading || _isLoadingLocation || _isSubmitting;
          final canSubmit = _currentPosition != null && !isLoading;

          return ElevatedButton(
            onPressed: canSubmit ? _submitCheckOut : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                : const Text('COMPLETE VISIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.3)),
          );
        },
      ),
    );
  }

  void _showSuccessDialog(String dealId) {
    bool isCollection = _selectedOutcome == 'collection';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(isCollection ? LucideIcons.checkCircle : LucideIcons.partyPopper, color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: 24),
            Text(isCollection ? 'SUCCESS!' : 'DEAL WON!', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Text(
              isCollection 
                ? 'Payment recorded and invoice updated.'
                : 'Session saved and deal has been processed.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final receiptService = sl<ReceiptService>();
                  await receiptService.generateAndShareReceipt(
                    customerName: widget.customerName ?? 'Customer',
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
                icon: const Icon(LucideIcons.download, color: Colors.white, size: 18),
                label: const Text('GENERATE RECEIPT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('LATER', style: TextStyle(color: AppColors.textPlaceholder, fontWeight: FontWeight.w900, fontSize: 12)),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (mounted) context.pop(true);
    });
  }
}
