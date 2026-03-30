import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../../domain/entities/task.dart' as ent;

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  static const Color _orange = Color(0xFFEA580C);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  int _selectedTab = 0;
  final List<String> _tabs = ['To-do', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() {
    ent.TaskStatus? status;
    if (_selectedTab == 0) status = ent.TaskStatus.TODO;
    if (_selectedTab == 1) status = ent.TaskStatus.IN_PROGRESS;
    if (_selectedTab == 2) status = ent.TaskStatus.COMPLETED;
    
    context.read<TaskBloc>().add(FetchTasks(status: status));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(child: CircularProgressIndicator(color: _orange));
                } else if (state is TasksLoaded) {
                  if (state.tasks.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildTaskList(state.tasks);
                } else if (state is TaskError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text('Tarik untuk memuat tugas'));
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.clipboardCheck, size: 64, color: _textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Tidak ada tugas',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 70,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.list, color: _orange, size: 22),
          ),
          const SizedBox(width: 12),
          const Text(
            'Tasks',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.search, color: Color(0xFF4B5563), size: 24),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () {
              context.pushNamed(kRouteNewTask).then((_) {
                _fetchTasks(); // Refresh when returning
              });
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: _orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.plus, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final isSelected = _selectedTab == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? _orange : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _tabs[index],
                      style: TextStyle(
                        color: isSelected ? _orange : _textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          _buildChip('Today', LucideIcons.calendar),
          const SizedBox(width: 8),
          _buildChip('High Priority', LucideIcons.alertCircle),
          const SizedBox(width: 8),
          _buildChip('Me', LucideIcons.user),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(LucideIcons.chevronDown, size: 14, color: _textSecondary),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<ent.Task> tasks) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildTaskCard(tasks[index], index);
      },
    );
  }

  Widget _buildTaskCard(ent.Task task, int index) {
    Color badgeColor;
    Color badgeBgColor;
    
    if (task.priority == ent.TaskPriority.HIGH) {
      badgeColor = const Color(0xFFDC2626);
      badgeBgColor = const Color(0xFFFEE2E2);
    } else if (task.priority == ent.TaskPriority.MEDIUM) {
      badgeColor = _orange;
      badgeBgColor = const Color(0xFFFFF7ED);
    } else {
      badgeColor = const Color(0xFF2563EB);
      badgeBgColor = const Color(0xFFDBEAFE);
    }

    final isCompleted = task.status == ent.TaskStatus.COMPLETED;
    final isOverdue = task.dueDate != null && task.dueDate!.isBefore(DateTime.now()) && !isCompleted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (!isCompleted) {
                context.read<TaskBloc>().add(CompleteTask(task.id));
              }
            },
            child: Container(
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted ? _orange : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: isCompleted ? _orange : Colors.grey.shade300, width: 1.5),
              ),
              child: isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          color: isCompleted ? Colors.grey : _textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.priority.name,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  task.description,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(isOverdue ? LucideIcons.alertCircle : LucideIcons.clock, 
                         size: 14, color: isOverdue ? Colors.red : _textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      task.dueDate != null ? DateFormat('MMM d, HH:mm').format(task.dueDate!) : 'No deadline',
                      style: TextStyle(
                        color: isOverdue ? Colors.red : _textSecondary,
                        fontSize: 12,
                        fontWeight: isOverdue ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (task.customerName != null) ...[
                      const Icon(LucideIcons.building2, size: 14, color: _textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          task.customerName!,
                          style: const TextStyle(color: _textSecondary, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(LucideIcons.home, 'HOME', false, () => context.goNamed(kRouteDashboard)),
          _buildNavItem(LucideIcons.checkSquare, 'TASKS', true, () {}),
          _buildNavItem(LucideIcons.users, 'LEADS', false, () {}),
          _buildNavItem(LucideIcons.building2, 'CLIENTS', false, () => context.goNamed(kRouteCustomers)),
          _buildNavItem(Icons.more_horiz, 'MORE', false, () {}),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? _orange : const Color(0xFF9CA3AF), size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? _orange : const Color(0xFF9CA3AF),
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
