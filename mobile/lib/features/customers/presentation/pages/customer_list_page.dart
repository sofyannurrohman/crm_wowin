import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../../../../core/router/app_router.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  void _fetchCustomers() {
    context.read<CustomerBloc>().add(FetchCustomers(query: _searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pelanggan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.pushNamed(kRouteAddCustomer),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pelanggan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _fetchCustomers();
                  },
                ),
              ),
              onSubmitted: (_) => _fetchCustomers(),
            ),
          ),
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CustomersLoaded) {
                  if (state.customers.isEmpty) {
                    return const Center(child: Text('Tidak ada pelanggan ditemukan'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _fetchCustomers(),
                    child: ListView.builder(
                      itemCount: state.customers.length,
                      itemBuilder: (context, index) {
                        final customer = state.customers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(customer.name[0].toUpperCase()),
                          ),
                          title: Text(customer.name),
                          subtitle: Text(customer.companyName ?? customer.industry ?? '-'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.pushNamed(
                            kRouteCustomerDetail,
                            pathParameters: {'id': customer.id},
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is CustomerError) {
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
}
