import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'map_picker_page.dart';
import 'live_photo_capture_page.dart';
import '../../domain/entities/sales_activity.dart';
import '../bloc/sales_activity_bloc.dart';
import '../bloc/sales_activity_event.dart';
import '../bloc/sales_activity_state.dart';
import '../../../leads/presentation/bloc/lead_bloc.dart';
import '../../../leads/presentation/bloc/lead_event.dart';
import '../../../leads/presentation/bloc/lead_state.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../deals/presentation/bloc/deal_bloc.dart';
import '../../../deals/presentation/bloc/deal_event.dart';
import '../../../deals/presentation/bloc/deal_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/theme/app_colors.dart';

class AddSalesActivityPage extends StatefulWidget {
  final SalesActivity? initialActivity;

  const AddSalesActivityPage({super.key, this.initialActivity});

  @override
  State<AddSalesActivityPage> createState() => _AddSalesActivityPageState();
}

class _AddSalesActivityPageState extends State<AddSalesActivityPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _outcomeController;

  String _selectedType = 'visit';
  String? _selectedLeadId;
  String? _selectedLeadName;
  String? _selectedCustomerId;
  String? _selectedCustomerName;
  String? _selectedDealId;
  String? _selectedDealTitle;

  LatLng? _selectedLocation;
  String? _address;
  String? _selfieBase64;
  Uint8List? _selfieBytes;
  String? _storefrontBase64;
  Uint8List? _storefrontBytes;
  DateTime? _checkInTime;

  final List<Map<String, dynamic>> _types = [
    {'value': 'visit', 'label': 'Visit', 'icon': LucideIcons.mapPin},
    {'value': 'negotiation', 'label': 'Negotiation', 'icon': LucideIcons.messageSquare},
    {'value': 'deal_closing', 'label': 'Deal / Closing', 'icon': LucideIcons.users},
    {'value': 'follow_up', 'label': 'Follow Up', 'icon': LucideIcons.phoneCall},
    {'value': 'other', 'label': 'Other', 'icon': LucideIcons.activity},
  ];

  String _closingStage = 'closed_won';

  @override
  void initState() {
    super.initState();
    final activity = widget.initialActivity;
    _titleController = TextEditingController(text: activity?.title ?? '');
    _notesController = TextEditingController(text: activity?.notes ?? '');
    _outcomeController = TextEditingController(text: activity?.outcome ?? '');
    _selectedType = activity?.activityType ?? 'visit';
    _selectedLeadId = activity?.leadId;
    _selectedLeadName = activity?.lead?.name;
    _selectedCustomerId = activity?.customerId;
    _selectedCustomerName = activity?.customer?.name;
    _selectedDealId = activity?.dealId;
    _selectedDealTitle = activity?.deal?.title;
    
    if (activity != null) {
      if (activity.selfiePhotoPath != null) {
        _selfieBase64 = activity.selfiePhotoPath;
        try { _selfieBytes = base64Decode(activity.selfiePhotoPath!); } catch(_) {}
      }
      if (activity.placePhotoPath != null) {
        _storefrontBase64 = activity.placePhotoPath;
        try { _storefrontBytes = base64Decode(activity.placePhotoPath!); } catch(_) {}
      }
      if (activity.latitude != null && activity.longitude != null) {
        _selectedLocation = LatLng(activity.latitude!, activity.longitude!);
      }
      _address = activity.address;
      _checkInTime = activity.checkInTime;
    } else {
      _checkInTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _outcomeController.dispose();
    super.dispose();
  }

  void _showLeadPicker() {
    context.read<LeadBloc>().add(const FetchLeads());
    _showCustomPicker(
      title: 'Select Lead',
      child: BlocBuilder<LeadBloc, LeadState>(
        builder: (context, state) {
          if (state is LeadLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          if (state is LeadsLoaded) {
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              itemCount: state.leads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final lead = state.leads[index];
                return _buildPickerItem(
                  icon: LucideIcons.user,
                  iconColor: const Color(0xFF3B82F6),
                  title: lead.name,
                  subtitle: lead.company ?? 'No Company',
                  onTap: () {
                    setState(() {
                      _selectedLeadId = lead.id;
                      _selectedLeadName = lead.name;
                      _selectedCustomerId = null;
                      _selectedCustomerName = null;
                      _selectedDealId = null;
                      _selectedDealTitle = null;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            );
          }
          return const Center(child: Text('Failed to load leads'));
        },
      ),
    );
  }

  void _showCustomerPicker() {
    context.read<CustomerBloc>().add(const FetchCustomers());
    _showCustomPicker(
      title: 'Select Customer',
      child: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          if (state is CustomersLoaded) {
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              itemCount: state.customers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final customer = state.customers[index];
                return _buildPickerItem(
                  icon: LucideIcons.building,
                  iconColor: const Color(0xFF0D9488),
                  title: customer.name,
                  subtitle: customer.companyName ?? 'No Company',
                  onTap: () {
                    setState(() {
                      _selectedCustomerId = customer.id;
                      _selectedCustomerName = customer.name;
                      _selectedLeadId = null;
                      _selectedLeadName = null;
                      _selectedDealId = null;
                      _selectedDealTitle = null;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            );
          }
          return const Center(child: Text('Failed to load customers'));
        },
      ),
    );
  }

  void _showDealPicker() {
    context.read<DealBloc>().add(const FetchDeals());
    _showCustomPicker(
      title: 'Select Deal',
      child: BlocBuilder<DealBloc, DealState>(
        builder: (context, state) {
          if (state is DealLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          if (state is DealsLoaded) {
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              itemCount: state.deals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final deal = state.deals[index];
                return _buildPickerItem(
                  icon: LucideIcons.briefcase,
                  iconColor: const Color(0xFF4F46E5),
                  title: deal.title,
                  subtitle: 'Rp ${NumberFormat('#,###', 'id_ID').format(deal.amount)}',
                  onTap: () {
                    setState(() {
                      _selectedDealId = deal.id;
                      _selectedDealTitle = deal.title;
                      _selectedCustomerId = deal.customerId;
                      _selectedCustomerName = deal.customer?.name;
                      _selectedLeadId = null;
                      _selectedLeadName = null;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            );
          }
          return const Center(child: Text('Failed to load deals'));
        },
      ),
    );
  }

  void _showCustomPicker({required String title, required Widget child}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerItem({required IconData icon, required Color iconColor, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9), width: 2)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: iconColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 20)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)), Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600))])),
            const Icon(LucideIcons.chevronRight, size: 18, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchAddress(LatLng loc) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${loc.latitude}&lon=${loc.longitude}&format=json'),
        headers: {'User-Agent': 'wowin_crm_mobile'},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (mounted) setState(() => _address = json['display_name']);
      }
    } catch (_) {}
  }

  Future<void> _getLocation() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => MapPickerPage(initialLocation: _selectedLocation)));
    if (result != null && result is LatLng) {
      setState(() => _selectedLocation = result);
      _fetchAddress(result);
    }
  }

  Future<void> _takePhoto() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const LivePhotoCapturePage()));
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selfieBase64 = result['selfie'];
        _storefrontBase64 = result['storefront'];
        if (_selfieBase64 != null) { try { _selfieBytes = base64Decode(_selfieBase64!); } catch(_) {} }
        if (_storefrontBase64 != null) { try { _storefrontBytes = base64Decode(_storefrontBase64!); } catch(_) {} }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == 'visit' && _selectedLocation == null && widget.initialActivity == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a location for the visit'), backgroundColor: Color(0xFFEF4444), behavior: SnackBarBehavior.floating));
        return;
      }

      final authState = context.read<AuthBloc>().state;
      String userId = '';
      if (authState is Authenticated) { userId = authState.user.id; } else if (widget.initialActivity != null) { userId = widget.initialActivity!.userId; }

      final activity = SalesActivity(
        id: widget.initialActivity?.id ?? const Uuid().v4(),
        title: _titleController.text,
        userId: userId,
        activityType: _selectedType,
        notes: _notesController.text,
        outcome: _outcomeController.text.isNotEmpty ? _outcomeController.text : null,
        leadId: _selectedLeadId,
        customerId: _selectedCustomerId,
        dealId: _selectedDealId,
        latitude: _selectedLocation?.latitude ?? widget.initialActivity?.latitude,
        longitude: _selectedLocation?.longitude ?? widget.initialActivity?.longitude,
        address: _address ?? widget.initialActivity?.address,
        selfiePhotoPath: _selfieBase64,
        placePhotoPath: _storefrontBase64,
        checkInTime: _selectedType == 'visit' ? _checkInTime : null,
        checkOutTime: widget.initialActivity?.checkOutTime,
        activityAt: widget.initialActivity?.activityAt ?? DateTime.now(),
        createdAt: widget.initialActivity?.createdAt ?? DateTime.now(),
      );

      if (widget.initialActivity == null) {
        context.read<SalesActivityBloc>().add(CreateSalesActivitySubmitted(activity));
      } else {
        context.read<SalesActivityBloc>().add(UpdateSalesActivitySubmitted(activity));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialActivity != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<SalesActivityBloc, SalesActivityState>(
        listener: (context, state) {
          if (state is SalesActivityOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating));
            if (_selectedDealId != null) {
              if (_selectedType == 'deal_closing') { context.read<DealBloc>().add(UpdateDealStageSubmitted(id: _selectedDealId!, stage: _closingStage)); }
              else if (_selectedType == 'negotiation') { context.read<DealBloc>().add(UpdateDealStageSubmitted(id: _selectedDealId!, stage: 'negotiation')); }
            }
            context.pop(true);
          } else if (state is SalesActivityError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating));
          }
        },
        child: Column(
          children: [
            _buildPremiumHeader(isEdit),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('ACTIVITY TYPE'),
                      const SizedBox(height: 12),
                      _buildTypeSelector(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('BASIC INFORMATION'),
                      const SizedBox(height: 12),
                      _buildTextField(controller: _titleController, label: 'Activity Title', hint: 'e.g., Shop Visit, Negotiation Call', icon: LucideIcons.edit3, validator: (v) => v!.isEmpty ? 'Title required' : null),
                      const SizedBox(height: 24),
                      _buildSectionTitle('LINK TO ENTITY (OPTIONAL)'),
                      const SizedBox(height: 12),
                      _buildPickerField(label: 'Lead', value: _selectedLeadName ?? 'Connect to Lead', icon: LucideIcons.user, iconColor: const Color(0xFF3B82F6), onTap: _showLeadPicker),
                      const SizedBox(height: 12),
                      _buildPickerField(label: 'Customer', value: _selectedCustomerName ?? 'Connect to Customer', icon: LucideIcons.building, iconColor: const Color(0xFF0D9488), onTap: _showCustomerPicker),
                      const SizedBox(height: 12),
                      _buildPickerField(label: 'Deal', value: _selectedDealTitle ?? 'Connect to Deal', icon: LucideIcons.briefcase, iconColor: const Color(0xFF4F46E5), onTap: _showDealPicker),
                      const SizedBox(height: 32),
                      
                      if (_selectedType == 'visit') ...[
                        _buildSectionTitle('VISIT VERIFICATION'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildVerificationButton(icon: LucideIcons.map, label: _selectedLocation != null ? 'Location Captured' : 'Select Location', color: const Color(0xFF10B981), isDone: _selectedLocation != null, onTap: _getLocation)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildVerificationButton(icon: LucideIcons.camera, label: _selfieBytes != null ? 'Photos Captured' : 'Capture Photos', color: const Color(0xFF3B82F6), isDone: _selfieBytes != null, onTap: _takePhoto)),
                          ],
                        ),
                        if (_address != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
                            child: Row(children: [const Icon(LucideIcons.mapPin, size: 14, color: AppColors.textPlaceholder), const SizedBox(width: 8), Expanded(child: Text(_address!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)))]),
                          ),
                        ],
                        if (_selfieBytes != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.memory(_selfieBytes!, height: 120, fit: BoxFit.cover))),
                              if (_storefrontBytes != null) ...[
                                const SizedBox(width: 12),
                                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.memory(_storefrontBytes!, height: 120, fit: BoxFit.cover))),
                              ]
                            ],
                          )
                        ],
                        const SizedBox(height: 32),
                      ],
                      
                      _buildSectionTitle('REMARKS & OUTCOME'),
                      const SizedBox(height: 12),
                      _buildTextField(controller: _notesController, label: 'Activity Notes', hint: 'Detail the discussion or next steps...', icon: LucideIcons.alignLeft, maxLines: 4),
                      if (_selectedType == 'negotiation' || _selectedType == 'deal_closing') ...[
                        const SizedBox(height: 16),
                        if (_selectedType == 'deal_closing') ...[
                          _buildClosingStageDropdown(),
                          const SizedBox(height: 16),
                        ],
                        _buildTextField(controller: _outcomeController, label: 'Final Outcome', hint: 'e.g., Agreed on Rp 5.000.000 pricing', icon: LucideIcons.checkCircle, maxLines: 2),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButton(isEdit),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(bool isEdit) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.premiumGradient, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40))),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () => context.pop(), icon: const Icon(LucideIcons.arrowLeft, color: Colors.white)),
                  Text(isEdit ? 'Update Activity' : 'New Activity Log', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Capture the Moment', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text('Detail your client interaction', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _types.length,
        itemBuilder: (context, index) {
          final type = _types[index];
          final isSelected = _selectedType == type['value'];
          return GestureDetector(
            onTap: () => setState(() => _selectedType = type['value']),
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(type['icon'], color: isSelected ? AppColors.primary : AppColors.textPlaceholder, size: 28),
                  const SizedBox(height: 8),
                  Text(type['label'], style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, color: isSelected ? AppColors.primary : AppColors.textSecondary), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPlaceholder, fontSize: 10, letterSpacing: 1.2));
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required IconData icon, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textPlaceholder),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }

  Widget _buildPickerField({required String label, required String value, required IconData icon, required Color iconColor, required VoidCallback onTap}) {
    final isPlaceholder = value.contains('Connect');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isPlaceholder ? const Color(0xFFF1F5F9) : iconColor.withOpacity(0.2))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.08), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 18)),
            const SizedBox(width: 16),
            Expanded(child: Text(value, style: TextStyle(fontSize: 14, color: isPlaceholder ? AppColors.textPlaceholder : AppColors.textPrimary, fontWeight: isPlaceholder ? FontWeight.w500 : FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (!isPlaceholder)
              IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(LucideIcons.x, size: 16, color: Color(0xFFEF4444)), onPressed: () => setState(() {
                if (label == 'Lead') { _selectedLeadId = null; _selectedLeadName = null; }
                if (label == 'Customer') { _selectedCustomerId = null; _selectedCustomerName = null; }
                if (label == 'Deal') { _selectedDealId = null; _selectedDealTitle = null; }
              }))
            else
              const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationButton({required IconData icon, required String label, required Color color, required bool isDone, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: isDone ? color.withOpacity(0.08) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDone ? color : const Color(0xFFF1F5F9), width: 2)),
        child: Column(
          children: [
            Icon(icon, color: isDone ? color : AppColors.textPlaceholder, size: 24),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isDone ? color : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildClosingStageDropdown() {
    return DropdownButtonFormField<String>(
      value: _closingStage,
      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Closing Status',
        prefixIcon: const Icon(LucideIcons.checkSquare, size: 18, color: AppColors.textPlaceholder),
        filled: true, fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
      items: const [
        DropdownMenuItem(value: 'closed_won', child: Text('Closed Won (Success)')),
        DropdownMenuItem(value: 'closed_lost', child: Text('Closed Lost (Failed)')),
      ],
      onChanged: (v) => setState(() => _closingStage = v!),
    );
  }

  Widget _buildBottomButton(bool isEdit) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: const Color(0xFFF1F5F9)))),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: BlocBuilder<SalesActivityBloc, SalesActivityState>(
        builder: (context, state) {
          final isLoading = state is SalesActivityLoading;
          return ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, disabledBackgroundColor: AppColors.primary.withOpacity(0.5), minimumSize: const Size(double.infinity, 64), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
            child: isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3) : Text(isEdit ? 'UPDATE ACTIVITY' : 'SAVE ACTIVITY', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.3)),
          );
        },
      ),
    );
  }
}
