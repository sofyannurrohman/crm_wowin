import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StockItem {
  final String name;
  int qty;
  String status; // 'good', 'low', 'out'

  StockItem({required this.name, this.qty = 0, this.status = 'good'});

  Map<String, dynamic> toJson() => {'name': name, 'qty': qty, 'status': status};
}

class StockCheckSheet extends StatefulWidget {
  final Function(String jsonData) onConfirm;

  const StockCheckSheet({super.key, required this.onConfirm});

  @override
  State<StockCheckSheet> createState() => _StockCheckSheetState();
}

class _StockCheckSheetState extends State<StockCheckSheet> {
  static const Color _orange = Color(0xFFEA580C);

  final List<StockItem> _items = [
    StockItem(name: 'Produk A'),
    StockItem(name: 'Produk B'),
    StockItem(name: 'Produk C'),
    StockItem(name: 'Produk D'),
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'low': return Colors.amber;
      case 'out': return Colors.red;
      default: return Colors.green;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'low': return LucideIcons.alertTriangle;
      case 'out': return LucideIcons.x;
      default: return LucideIcons.checkCircle;
    }
  }

  void _confirm() {
    final json = jsonEncode(_items.map((e) => e.toJson()).toList());
    widget.onConfirm(json);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _orange.withOpacity(0.1),
                child: Icon(LucideIcons.clipboardList, color: _orange, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stock Check', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('Periksa stok produk di toko', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...List.generate(_items.length, (i) {
            final item = _items[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                      Icon(_statusIcon(item.status), size: 18, color: _statusColor(item.status)),
                      const SizedBox(width: 4),
                      Text(
                        item.status.toUpperCase(),
                        style: TextStyle(color: _statusColor(item.status), fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Stok:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => setState(() { if (item.qty > 0) item.qty--; }),
                        icon: const Icon(LucideIcons.minus, size: 16),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.all(6),
                          minimumSize: Size.zero,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      ),
                      IconButton(
                        onPressed: () => setState(() => item.qty++),
                        icon: const Icon(LucideIcons.plus, size: 16),
                        style: IconButton.styleFrom(
                          backgroundColor: _orange.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.all(6),
                          minimumSize: Size.zero,
                          foregroundColor: _orange,
                        ),
                      ),
                      const Spacer(),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'good', label: Text('OK', style: TextStyle(fontSize: 11))),
                          ButtonSegment(value: 'low', label: Text('Low', style: TextStyle(fontSize: 11))),
                          ButtonSegment(value: 'out', label: Text('Out', style: TextStyle(fontSize: 11))),
                        ],
                        selected: {item.status},
                        onSelectionChanged: (val) => setState(() => item.status = val.first),
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _confirm,
              icon: const Icon(LucideIcons.checkCircle, size: 18),
              label: const Text('KONFIRMASI STOK', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
