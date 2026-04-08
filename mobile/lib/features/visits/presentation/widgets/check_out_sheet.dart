import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';
import 'stock_check_sheet.dart';
import '../pages/visit_summary_result_page.dart';

class CheckOutSheet extends StatefulWidget {
  final String scheduleId;
  final String customerName;
  final DateTime? visitStartTime;

  const CheckOutSheet({
    super.key,
    required this.scheduleId,
    required this.customerName,
    this.visitStartTime,
  });

  @override
  State<CheckOutSheet> createState() => _CheckOutSheetState();
}

class _CheckOutSheetState extends State<CheckOutSheet> {
  final TextEditingController _nextActionController = TextEditingController();
  String _selectedResult = 'Interested';
  DateTime? _nextVisitDate;
  bool _isSubmitting = false;

  // Enhanced data
  String? _inventoryJson;
  bool _requiresSignature = false;
  final GlobalKey<_SignaturePadState> _signatureKey = GlobalKey();
  bool _signatureCaptured = false;

  final List<String> _results = [
    'PO Submitted',
    'Sample Given',
    'Price Negotiation',
    'Inventory Check',
    'Follow Up Required',
    'Reschedule',
    'Rejected',
    'No Answer',
  ];

  // Outcomes that require a signature
  final Set<String> _signatureRequired = {'PO Submitted', 'Sample Given'};

  static const Color _orange = Color(0xFFEA580C);
  static const Color _navy = Color(0xFF1A237E);

  Future<void> _submit() async {
    // Check if signature is needed
    if (_requiresSignature && !_signatureCaptured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanda tangan pelanggan diperlukan untuk hasil ini.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      // Save signature to file if captured
      String? signaturePath;
      if (_signatureCaptured) {
        final sigBytes = await _signatureKey.currentState?.exportSignature();
        if (sigBytes != null) {
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png');
          await file.writeAsBytes(sigBytes);
          signaturePath = file.path;
        }
      }

      final String? currentDealId = (context.read<VisitBloc>().state is VisitSuccess) 
          ? (context.read<VisitBloc>().state as VisitSuccess).currentDealId 
          : null;

      context.read<VisitBloc>().add(
        CheckOutSubmitted(
          scheduleId: widget.scheduleId,
          latitude: position.latitude,
          longitude: position.longitude,
          visitResult: _selectedResult,
          nextAction: _nextActionController.text,
          nextVisitDate: _nextVisitDate != null ? DateFormat('yyyy-MM-dd').format(_nextVisitDate!) : '',
          signaturePath: signaturePath,
          inventoryData: _inventoryJson,
          dealId: currentDealId,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _openStockCheck() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StockCheckSheet(
        onConfirm: (json) => setState(() => _inventoryJson = json),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitBloc, VisitState>(
      listener: (context, state) {
        if (state is VisitSuccess) {
          Navigator.pop(context); // Close sheet

          // Calculate visit duration if we have the start time
          final duration = widget.visitStartTime != null
              ? DateTime.now().difference(widget.visitStartTime!)
              : const Duration(minutes: 30);

          // Navigate to the premium summary screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VisitSummaryResultPage(
                customerName: widget.customerName,
                outcome: _selectedResult,
                nextAction: _nextActionController.text,
                visitDuration: duration,
                checkInTime: widget.visitStartTime ?? DateTime.now().subtract(duration),
                checkOutTime: DateTime.now(),
                hasSignature: _signatureCaptured,
                hasInventory: _inventoryJson != null,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFFEF2F2),
                    child: Icon(LucideIcons.logOut, color: Colors.red, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Laporan Kunjungan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        Text(widget.customerName, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Outcome selection ───────────────────────────
              const Text('HASIL KUNJUNGAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _results.map((r) {
                  final isSelected = _selectedResult == r;
                  return ChoiceChip(
                    label: Text(r),
                    selected: isSelected,
                    onSelected: (_) => setState(() {
                      _selectedResult = r;
                      _requiresSignature = _signatureRequired.contains(r);
                    }),
                    selectedColor: _orange.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? _orange : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: isSelected ? _orange : Colors.grey.shade300),
                    ),
                  );
                }).toList(),
              ),

              // ── Signature required badge ────────────────────
              if (_requiresSignature) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.pencil, size: 14, color: Color(0xFF0EA5E9)),
                      SizedBox(width: 8),
                      Text(
                        'Tanda tangan pelanggan diperlukan untuk hasil ini',
                        style: TextStyle(fontSize: 12, color: Color(0xFF0369A1), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── Linked Deal Info ────────────────────────────
              BlocBuilder<VisitBloc, VisitState>(
                builder: (context, state) {
                  if (state is VisitSuccess && state.currentDealId != null) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.shoppingBag, size: 20, color: Color(0xFF10B981)),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Penjualan Terdaftar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                                Text('Deal akan otomatis ditandai sebagai WON jika PO dikirim.', style: TextStyle(fontSize: 11, color: Color(0xFF065F46))),
                              ],
                            ),
                          ),
                          if (_selectedResult == 'PO Submitted')
                            const Icon(LucideIcons.checkCircle, color: Color(0xFF10B981), size: 20),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),

              // ── Stock check button ──────────────────────────
              InkWell(
                onTap: _openStockCheck,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _inventoryJson != null
                        ? const Color(0xFF6366F1).withOpacity(0.06)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _inventoryJson != null ? const Color(0xFF6366F1).withOpacity(0.3) : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.clipboardList,
                        size: 18,
                        color: _inventoryJson != null ? const Color(0xFF6366F1) : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _inventoryJson != null ? 'Stok sudah dicatat ✓' : 'Periksa Stok (Opsional)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _inventoryJson != null ? const Color(0xFF6366F1) : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Signature pad ───────────────────────────────
              if (_requiresSignature) ...[
                const Text('TANDA TANGAN PELANGGAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
                const SizedBox(height: 12),
                _SignaturePad(
                  key: _signatureKey,
                  onSigned: () => setState(() => _signatureCaptured = true),
                  onCleared: () => setState(() => _signatureCaptured = false),
                ),
                const SizedBox(height: 16),
              ],

              // ── Next action ────────────────────────────────
              const Text('TINDAKAN SELANJUTNYA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 12),
              TextField(
                controller: _nextActionController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Kirim penawaran besok',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 24),

              // ── Schedule next visit ────────────────────────
              const Text('JADWAL KUNJUNGAN BERIKUTNYA (OPSIONAL)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _nextVisitDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.calendar, size: 20, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        _nextVisitDate != null
                            ? DateFormat('EEEE, d MMMM yyyy').format(_nextVisitDate!)
                            : 'Pilih tanggal...',
                        style: TextStyle(
                          color: _nextVisitDate != null ? Colors.black : Colors.grey,
                          fontWeight: _nextVisitDate != null ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: const Icon(LucideIcons.checkCircle, size: 18),
                  label: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SUBMIT HASIL KUNJUNGAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Signature Pad Widget
// ─────────────────────────────────────────────────────────
class _SignaturePad extends StatefulWidget {
  final VoidCallback onSigned;
  final VoidCallback onCleared;

  const _SignaturePad({super.key, required this.onSigned, required this.onCleared});

  @override
  State<_SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<_SignaturePad> {
  final List<Offset?> _points = [];
  bool get _hasSignature => _points.any((p) => p != null);

  Future<Uint8List?> exportSignature() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(300, 150);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawColor(Colors.white, BlendMode.src);
    for (int i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hasSignature ? const Color(0xFF0EA5E9) : Colors.grey.shade300,
              width: _hasSignature ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  final box = context.findRenderObject() as RenderBox?;
                  final local = box?.globalToLocal(details.globalPosition) ?? details.localPosition;
                  _points.add(local);
                });
                if (!_hasSignature) return;
                widget.onSigned();
              },
              onPanEnd: (_) {
                setState(() => _points.add(null));
                if (_hasSignature) widget.onSigned();
              },
              child: CustomPaint(
                painter: _SignaturePainter(_points),
                child: _points.isEmpty
                    ? Center(
                        child: Text(
                          'Tanda tangan di sini',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
        if (_hasSignature)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() => _points.clear());
                widget.onCleared();
              },
              icon: const Icon(LucideIcons.trash2, size: 14),
              label: const Text('Hapus'),
              style: TextButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 8)),
            ),
          ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) => old.points != points;
}
