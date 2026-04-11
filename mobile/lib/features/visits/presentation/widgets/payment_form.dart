import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PaymentForm extends StatefulWidget {
  final double amount;
  final Function(String method, String? ref) onChanged;

  const PaymentForm({super.key, required this.amount, required this.onChanged});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  String _method = 'cash';
  final TextEditingController _refController = TextEditingController();

  final Map<String, String> _methodLabels = {
    'cash': 'Tunai / Cash',
    'transfer': 'Transfer Bank',
    'credit': 'Piutang / Credit',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metode Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: _methodLabels.entries.map((entry) {
            final isSelected = _method == entry.key;
            return ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _method = entry.key);
                  widget.onChanged(_method, _refController.text);
                }
              },
              selectedColor: const Color(0xFFE8622A).withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFE8622A) : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isSelected ? const Color(0xFFE8622A) : Colors.grey.shade300),
              ),
            );
          }).toList(),
        ),
        if (_method != 'cash') ...[
          const SizedBox(height: 16),
          TextField(
            controller: _refController,
            decoration: InputDecoration(
              labelText: _method == 'transfer' ? 'Nomor Referensi Transfer' : 'Catatan Kredit',
              hintText: _method == 'transfer' ? 'Masukkan 4 digit terakhir' : 'Jatuh tempo dsb',
              prefixIcon: const Icon(LucideIcons.hash, size: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (val) => widget.onChanged(_method, val),
          ),
        ],
      ],
    );
  }
}
