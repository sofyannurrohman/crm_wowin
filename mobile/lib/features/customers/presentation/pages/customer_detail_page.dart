import 'package:flutter/material.dart';

class CustomerDetailPage extends StatelessWidget {
  final String id;
  const CustomerDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pelanggan')),
      body: Center(child: Text('Detail Pelanggan ID: $id')),
    );
  }
}

class AddCustomerPage extends StatelessWidget {
  const AddCustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pelanggan')),
      body: const Center(child: Text('Form Tambah Pelanggan')),
    );
  }
}
