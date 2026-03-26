import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lead_bloc.dart';
import '../bloc/lead_event.dart';
import '../bloc/lead_state.dart';

class LeadListPage extends StatefulWidget {
  const LeadListPage({super.key});

  @override
  State<LeadListPage> createState() => _LeadListPageState();
}

class _LeadListPageState extends State<LeadListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchLeads();
  }

  void _fetchLeads() {
    String? status;
    switch (_tabController.index) {
      case 0: status = 'new'; break;
      case 1: status = 'contacted'; break;
      case 2: status = 'qualified'; break;
      case 3: status = 'unqualified'; break;
    }
    context.read<LeadBloc>().add(FetchLeads(status: status));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (_) => _fetchLeads(),
          tabs: const [
            Tab(text: 'Baru'),
            Tab(text: 'Dihubungi'),
            Tab(text: 'Berkualitas'),
            Tab(text: 'Tidak Berkualitas'),
          ],
        ),
      ),
      body: BlocBuilder<LeadBloc, LeadState>(
        builder: (context, state) {
          if (state is LeadLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LeadsLoaded) {
            if (state.leads.isEmpty) {
              return const Center(child: Text('Tidak ada leads di kategori ini'));
            }
            return RefreshIndicator(
              onRefresh: () async => _fetchLeads(),
              child: ListView.builder(
                itemCount: state.leads.length,
                itemBuilder: (context, index) {
                  final lead = state.leads[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(lead.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lead.name),
                          if (lead.company != null) Text(lead.company!),
                        ],
                      ),
                      trailing: Text(
                        lead.estimatedValue != null ? 'Rp ${lead.estimatedValue}' : '-',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is LeadError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
