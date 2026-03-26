import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../../../../core/api/api_endpoints.dart';

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() {
    context.read<AttendanceBloc>().add(
          FetchAttendanceHistory(
            month: selectedDate.month,
            year: selectedDate.year,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
        actions: [
          IconButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != selectedDate) {
                setState(() {
                  selectedDate = picked;
                });
                _fetchHistory();
              }
            },
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryHeader(),
          Expanded(
            child: BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                if (state is AttendanceLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AttendanceHistoryLoaded) {
                  if (state.history.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildHistoryList(state.history);
                } else if (state is AttendanceError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(selectedDate),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Text('Ringkasan kehadiran bulan ini'),
            ],
          ),
          ElevatedButton.icon(
            onPressed: _fetchHistory,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Tidak ada data absensi untuk bulan ini'),
        ],
      ),
    );
  }

  Widget _buildHistoryList(history) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final record = history[index];
        final bool isClockIn = record.type == 'clock_in';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isClockIn ? Colors.green.shade50 : Colors.orange.shade50,
              child: Icon(
                isClockIn ? Icons.login : Icons.logout,
                color: isClockIn ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(
              isClockIn ? 'Clock In' : 'Clock Out',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('dd MMM yyyy, HH:mm').format(record.timestampAt)),
                if (record.address != null)
                  Text(
                    record.address!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDetail(record),
          ),
        );
      },
    );
  }

  void _showDetail(record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              record.type == 'clock_in' ? 'Detail Clock In' : 'Detail Clock Out',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailItem('Waktu', DateFormat('dd MMMM yyyy, HH:mm:ss').format(record.timestampAt)),
            _buildDetailItem('Lokasi', record.address ?? 'Lokasi tidak tersedia'),
            if (record.notes != null && record.notes!.isNotEmpty)
              _buildDetailItem('Catatan', record.notes!),
            const SizedBox(height: 16),
            if (record.photoPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  // In real app, prefix with baseUrl
                  ApiEndpoints.uploadsBaseUrl + record.photoPath!, 
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[100],
                    child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
