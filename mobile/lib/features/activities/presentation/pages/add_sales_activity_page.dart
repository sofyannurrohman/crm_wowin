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

  String _selectedType = 'visit';
  String? _selectedLeadId;
  String? _selectedLeadName;
  String? _selectedCustomerId;
  String? _selectedCustomerName;
  String? _selectedDealId;
  String? _selectedDealTitle;

  // Additional fields for Visit
  LatLng? _selectedLocation;
  String? _address;
  String? _selfieBase64;
  Uint8List? _selfieBytes;
  String? _storefrontBase64;
  Uint8List? _storefrontBytes;
  DateTime? _checkInTime;

  late TextEditingController _outcomeController;

  final List<Map<String, dynamic>> _types = [
    {'value': 'visit', 'label': 'Kunjungan', 'icon': LucideIcons.mapPin},
    {'value': 'negotiation', 'label': 'Negosiasi', 'icon': LucideIcons.messageSquare},
    {'value': 'deal_closing', 'label': 'Deal / Closing', 'icon': LucideIcons.users},
    {'value': 'follow_up', 'label': 'Follow Up', 'icon': LucideIcons.phoneCall},
    {'value': 'other', 'label': 'Lainnya', 'icon': LucideIcons.activity},
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
    
    // Existing visit data
    if (activity != null) {
      if (activity.photoBase64 != null) {
        _selfieBase64 = activity.photoBase64;
        try { _selfieBytes = base64Decode(activity.photoBase64!); } catch(_) {}
      }
      if (activity.storefrontPhotoBase64 != null) {
        _storefrontBase64 = activity.storefrontPhotoBase64;
        try { _storefrontBytes = base64Decode(activity.storefrontPhotoBase64!); } catch(_) {}
      }
      if (activity.latitude != null && activity.longitude != null) {
        _selectedLocation = LatLng(activity.latitude!, activity.longitude!);
      }
      _address = activity.address;
      _checkInTime = activity.checkInTime;
    } else {
      _checkInTime = DateTime.now(); // default checkin time
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Pilih Lead',
        child: BlocBuilder<LeadBloc, LeadState>(
          builder: (context, state) {
            if (state is LeadLoading) return const Center(child: CircularProgressIndicator());
            if (state is LeadsLoaded) {
              return ListView.builder(
                itemCount: state.leads.length,
                itemBuilder: (context, index) {
                  final lead = state.leads[index];
                  return ListTile(
                    leading: const Icon(LucideIcons.user, color: Colors.blueGrey),
                    title: Text(lead.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(lead.company ?? 'No Company'),
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
            return const Center(child: Text('Gagal memuat lead'));
          },
        ),
      ),
    );
  }

  void _showCustomerPicker() {
    context.read<CustomerBloc>().add(const FetchCustomers());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Pilih Customer',
        child: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            if (state is CustomerLoading) return const Center(child: CircularProgressIndicator());
            if (state is CustomersLoaded) {
              return ListView.builder(
                itemCount: state.customers.length,
                itemBuilder: (context, index) {
                  final customer = state.customers[index];
                  return ListTile(
                    leading: const Icon(LucideIcons.building, color: Colors.teal),
                    title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(customer.companyName ?? 'No Company'),
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
            return const Center(child: Text('Gagal memuat customer'));
          },
        ),
      ),
    );
  }

  void _showDealPicker() {
    context.read<DealBloc>().add(const FetchDeals());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Pilih Deal',
        child: BlocBuilder<DealBloc, DealState>(
          builder: (context, state) {
            if (state is DealLoading) return const Center(child: CircularProgressIndicator());
            if (state is DealsLoaded) {
              return ListView.builder(
                itemCount: state.deals.length,
                itemBuilder: (context, index) {
                  final deal = state.deals[index];
                  return ListTile(
                    leading: const Icon(LucideIcons.briefcase, color: Colors.indigo),
                    title: Text(deal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Rp ${NumberFormat('#,###', 'id_ID').format(deal.amount)}'),
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
            return const Center(child: Text('Gagal memuat deal'));
          },
        ),
      ),
    );
  }

  Widget _buildPickerSheet({required String title, required Widget child}) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: child),
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
        if (mounted) {
          setState(() {
            _address = json['display_name'];
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _getLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapPickerPage(
          initialLocation: _selectedLocation,
      )),
    );

    if (result != null && result is LatLng) {
      setState(() {
        _selectedLocation = result;
      });
      _fetchAddress(result);
    }
  }

  Future<void> _takePhoto() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LivePhotoCapturePage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selfieBase64 = result['selfie'];
        _storefrontBase64 = result['storefront'];
        
        if (_selfieBase64 != null) {
          try { _selfieBytes = base64Decode(_selfieBase64!); } catch(_) {}
        }
        if (_storefrontBase64 != null) {
          try { _storefrontBytes = base64Decode(_storefrontBase64!); } catch(_) {}
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == 'visit' && _selectedLocation == null && widget.initialActivity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap pilih lokasi pada peta untuk Kunjungan'), backgroundColor: Colors.red),
        );
        return;
      }

      final authState = context.read<AuthBloc>().state;
      String userId = '';
      if (authState is Authenticated) {
        userId = authState.user.id;
      } else if (widget.initialActivity != null) {
        userId = widget.initialActivity!.userId;
      }

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
        photoBase64: _selfieBase64,
        storefrontPhotoBase64: _storefrontBase64,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Aktivitas' : 'Catat Aktivitas Baru', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<SalesActivityBloc, SalesActivityState>(
        listener: (context, state) {
          if (state is SalesActivityOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            
            // Auto update deal stage
            if (_selectedDealId != null) {
              if (_selectedType == 'deal_closing' || _selectedType == 'closing') {
                context.read<DealBloc>().add(UpdateDealStageSubmitted(id: _selectedDealId!, stage: _closingStage));
              } else if (_selectedType == 'negotiation') {
                context.read<DealBloc>().add(UpdateDealStageSubmitted(id: _selectedDealId!, stage: 'negotiation'));
              }
            }
            
            context.pop(true);
          } else if (state is SalesActivityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Tipe & Judul', LucideIcons.type),
                const SizedBox(height: 16),
                const Text('Apa yang kamu lakukan?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 12),
                SizedBox(
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
                            color: isSelected ? const Color(0xFFE8622A).withOpacity(0.1) : Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFE8622A) : Colors.grey[200]!,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(type['icon'], color: isSelected ? const Color(0xFFE8622A) : Colors.grey[400], size: 28),
                              const SizedBox(height: 8),
                              Text(
                                type['label'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? const Color(0xFFE8622A) : Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _titleController,
                  label: 'Judul Aktivitas',
                  hint: 'Contoh: Kunjungan Toko Kelontong Berkah',
                  icon: LucideIcons.edit3,
                  validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Hubungkan Dengan (Opsional)', LucideIcons.link2),
                const SizedBox(height: 16),
                _buildPickerField(
                  label: 'Lead',
                  value: _selectedLeadName ?? 'Hubungkan dengan Lead',
                  icon: LucideIcons.user,
                  onTap: _showLeadPicker,
                ),
                const SizedBox(height: 12),
                _buildPickerField(
                  label: 'Customer',
                  value: _selectedCustomerName ?? 'Hubungkan dengan Customer',
                  icon: LucideIcons.building,
                  onTap: _showCustomerPicker,
                ),
                const SizedBox(height: 12),
                _buildPickerField(
                  label: 'Deal',
                  value: _selectedDealTitle ?? 'Hubungkan dengan Deal',
                  icon: LucideIcons.briefcase,
                  onTap: _showDealPicker,
                ),
                const SizedBox(height: 24),
                
                // --- VISITOR SECTION ---
                if (_selectedType == 'visit') ...[
                  _buildSectionHeader('Verifikasi Kunjungan', LucideIcons.mapPin),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _getLocation,
                          icon: Icon(LucideIcons.map, color: _selectedLocation != null ? Colors.green : const Color(0xFFE8622A), size: 18),
                          label: Text(_selectedLocation != null ? 'Lokasi Tersimpan' : 'Pilih Lokasi', style: TextStyle(color: _selectedLocation != null ? Colors.green : const Color(0xFFE8622A))),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _selectedLocation != null ? Colors.green : const Color(0xFFE8622A)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _takePhoto,
                          icon: Icon(LucideIcons.camera, color: _selfieBytes != null ? Colors.blue : const Color(0xFFE8622A), size: 18),
                          label: Text(_selfieBytes != null ? 'Foto Tersimpan' : 'Ambil Foto', style: TextStyle(color: _selfieBytes != null ? Colors.blue : const Color(0xFFE8622A))),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _selfieBytes != null ? Colors.blue : const Color(0xFFE8622A)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_address != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.mapPin, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(_address!, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        ),
                      ],
                    ),
                  ],
                  if (_selfieBytes != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(_selfieBytes!, height: 120, width: double.infinity, fit: BoxFit.cover),
                          ),
                        ),
                        if (_storefrontBytes != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(_storefrontBytes!, height: 120, width: double.infinity, fit: BoxFit.cover),
                            ),
                          ),
                        ]
                      ],
                    )
                  ],
                  const SizedBox(height: 24),
                ],
                
                _buildSectionHeader('Catatan & Detail', LucideIcons.fileText),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _notesController,
                  label: 'Catatan Aktivitas',
                  hint: 'Tuliskan hasil diskusi, feedback, atau langkah selanjutnya...',
                  icon: LucideIcons.alignLeft,
                  maxLines: 5,
                ),
                if (_selectedType == 'negotiation' || _selectedType == 'deal_closing' || _selectedType == 'closing') ...[
                  const SizedBox(height: 16),
                  if (_selectedType == 'deal_closing' || _selectedType == 'closing') ...[
                    DropdownButtonFormField<String>(
                      value: _closingStage,
                      decoration: InputDecoration(
                        labelText: 'Status Kesepakatan',
                        prefixIcon: const Icon(LucideIcons.checkSquare, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'closed_won', child: Text('Kesepakatan Berhasil (Closed Won)')),
                        DropdownMenuItem(value: 'closed_lost', child: Text('Kesepakatan Gagal (Closed Lost)')),
                      ],
                      onChanged: (v) => setState(() => _closingStage = v!),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildTextField(
                    controller: _outcomeController,
                    label: 'Hasil (Outcome)',
                    hint: 'Contoh: Pelanggan sepakat harga Rp 1.500.000',
                    icon: LucideIcons.checkCircle,
                    maxLines: 2,
                  ),
                ],
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: BlocBuilder<SalesActivityBloc, SalesActivityState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is SalesActivityLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8622A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        child: state is SalesActivityLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                isEdit ? 'Simpan Perubahan' : 'Catat Aktivitas',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE8622A)),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Color(0xFF8E8E93),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8622A), width: 2),
        ),
      ),
    );
  }

  Widget _buildPickerField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isPlaceholder = value.contains('Hubungkan');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: isPlaceholder ? Colors.grey.shade200 : const Color(0xFFE8622A).withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
          color: isPlaceholder ? Colors.grey[50] : const Color(0xFFE8622A).withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isPlaceholder ? Colors.grey : const Color(0xFFE8622A)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isPlaceholder ? Colors.grey : Colors.black,
                  fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!isPlaceholder)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(LucideIcons.x, size: 16, color: Colors.red),
                onPressed: () {
                  setState(() {
                    if (label == 'Lead') { _selectedLeadId = null; _selectedLeadName = null; }
                    if (label == 'Customer') { _selectedCustomerId = null; _selectedCustomerName = null; }
                    if (label == 'Deal') { _selectedDealId = null; _selectedDealTitle = null; }
                  });
                },
              )
            else
              const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
