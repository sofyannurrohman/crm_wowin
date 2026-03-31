import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../bloc/lead_bloc.dart';
import '../bloc/lead_event.dart';
import '../bloc/lead_state.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/app_sidebar.dart';

class LeadListPage extends StatefulWidget {
  const LeadListPage({super.key});

  @override
  State<LeadListPage> createState() => _LeadListPageState();
}

class _LeadListPageState extends State<LeadListPage> {
  final TextEditingController _searchController = TextEditingController();
  
  static const Color _orange = Color(0xFFEA580C);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Semua', 'Baru', 'Dihubungi', 'Memenuhi Syarat'];

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  void _fetchLeads() {
    String? status;
    switch (_selectedTabIndex) {
      case 0:
        status = null;
        break;
      case 1:
        status = 'new';
        break;
      case 2:
        status = 'contacted';
        break;
      case 3:
        status = 'qualified';
        break;
    }
    context.read<LeadBloc>().add(
          FetchLeads(
            query: _searchController.text,
            status: status,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      drawer: const AppSidebar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterTabs(),
          Expanded(child: _buildLeadsList()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 80,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.users, color: _orange, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Prospek',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Kelola calon pelanggan Anda',
                style: TextStyle(
                  color: _textSecondary.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () => context.pushNamed(kRouteAddLead),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: _orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.grey.shade200, height: 1.0),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Cari prospek dari nama, email atau sumber...',
            hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            prefixIcon: Icon(LucideIcons.search, color: Color(0xFF9CA3AF), size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
          onSubmitted: (_) => _fetchLeads(),
          onChanged: (val) {
            if (val.isEmpty) _fetchLeads();
          },
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
              _fetchLeads();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? _orange : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? _orange : Colors.grey.shade200,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Text(
                    _tabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : _textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  if (_tabs[index] == 'Baru') ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '12',
                        style: TextStyle(
                          color: isSelected ? Colors.white : _textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeadsList() {
    return BlocBuilder<LeadBloc, LeadState>(
      builder: (context, state) {
        if (state is LeadLoading) {
          return const Center(child: CircularProgressIndicator(color: _orange));
        } else if (state is LeadsLoaded) {
          if (state.leads.isEmpty) {
            return Center(
              child: Text(
                'Prospek tidak ditemukan',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async => _fetchLeads(),
            color: _orange,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: state.leads.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final lead = state.leads[index];
                return _buildLeadCard(lead);
              },
            ),
          );
        } else if (state is LeadError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildLeadCard(dynamic lead) {
    // Determine Mock Image or Initials based on Name
    String initials = '';
    if (lead.name.isNotEmpty) {
      final parts = lead.name.split(' ');
      if (parts.length > 1) {
        initials = '${parts[0][0]}${parts[1][0]}';
      } else {
        initials = parts[0][0];
      }
    }

    // Colors mapping logic matching mock
    Color badgeColor;
    Color badgeBgColor;
    Color badgeTextColor;
    String statusStr = (lead.status ?? 'BARU').toUpperCase();

    if (statusStr == 'NEW' || statusStr == 'BARU') {
      badgeColor = const Color(0xFF3B82F6);
      badgeBgColor = const Color(0xFFDBEAFE);
      badgeTextColor = const Color(0xFF1D4ED8);
      statusStr = 'BARU';
    } else if (statusStr == 'CONTACTED' || statusStr == 'DIHUBUNGI') {
      badgeColor = const Color(0xFFF59E0B);
      badgeBgColor = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFFB45309);
      statusStr = 'DIHUBUNGI';
    } else if (statusStr == 'QUALIFIED' || statusStr == 'MEMENUHI SYARAT') {
      badgeColor = const Color(0xFF10B981);
      badgeBgColor = const Color(0xFFD1FAE5);
      badgeTextColor = const Color(0xFF047857);
      statusStr = 'MEMENUHI SYARAT';
    } else {
      badgeColor = const Color(0xFF6B7280);
      badgeBgColor = const Color(0xFFF3F4F6);
      badgeTextColor = const Color(0xFF374151);
      statusStr = 'DIARSIPKAN'; // Fallback
    }

    IconData sourceIcon = LucideIcons.globe;
    String sourceText = lead.source.isNotEmpty ? (lead.source[0].toUpperCase() + lead.source.substring(1)) : 'Tidak Diketahui';
    if (sourceText.toLowerCase().contains('referral')) {
      sourceIcon = LucideIcons.share2;
    } else if (sourceText.toLowerCase().contains('email')) {
      sourceIcon = LucideIcons.mail;
    } else if (sourceText.toLowerCase().contains('phone') || sourceText.toLowerCase().contains('call')) {
      sourceIcon = LucideIcons.phone;
    }

    return InkWell(
      onTap: () => context.pushNamed(kRouteConvertLead, extra: lead),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar Stack
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getInitialsColor(initials),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: _getInitialsTextColor(initials),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        lead.name,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusStr,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(sourceIcon, size: 12, color: _textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      sourceText,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DITAMBAHKAN BARU-BARU INI', // Backend mapping when tracking is available
                      style: TextStyle(
                        color: _textSecondary.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Icon(Icons.more_vert, size: 20, color: Color(0xFF9CA3AF)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Color _getInitialsColor(String initials) {
    if (initials == 'MK') return const Color(0xFFFFF7ED);
    return const Color(0xFFF3F4F6); // For EP
  }

  Color _getInitialsTextColor(String initials) {
    if (initials == 'MK') return _orange;
    return const Color(0xFF4B5563); // For EP
  }

}

