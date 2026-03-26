import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/deal_bloc.dart';
import '../bloc/deal_event.dart';
import '../bloc/deal_state.dart';
import '../../domain/entities/deal.dart';

class DealKanbanPage extends StatefulWidget {
  const DealKanbanPage({super.key});

  @override
  State<DealKanbanPage> createState() => _DealKanbanPageState();
}

class _DealKanbanPageState extends State<DealKanbanPage> {
  final List<String> stages = [
    'prospecting',
    'qualification',
    'proposal',
    'negotiation',
    'closed_won',
    'closed_lost'
  ];

  @override
  void initState() {
    super.initState();
    context.read<DealBloc>().add(FetchDeals());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deals Pipeline'),
      ),
      body: BlocBuilder<DealBloc, DealState>(
        builder: (context, state) {
          if (state is DealLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DealsLoaded) {
            return _buildKanbanBoard(state.deals);
          } else if (state is DealError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildKanbanBoard(List<Deal> deals) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      itemCount: stages.length,
      itemBuilder: (context, index) {
        final stage = stages[index];
        final stageDeals = deals.where((d) => d.stage == stage).toList();

        return Container(
          width: 300,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatStageName(stage),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${stageDeals.length}'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: stageDeals.length,
                  itemBuilder: (context, idx) {
                    final deal = stageDeals[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deal.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp ${deal.amount ?? 0}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (deal.expectedClose != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Close: ${deal.expectedClose!.toIso8601String().split('T')[0]}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatStageName(String stage) {
    return stage
        .split('_')
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }
}
