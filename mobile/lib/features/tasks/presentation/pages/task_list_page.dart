import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/app_sidebar.dart';
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
  // changed orange -> new green #0D8549
  static const Color _orange = Color(0xFF0D8549);
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
    if (_selectedTab == 0) status = ent.TaskStatus.pending;
    if (_selectedTab == 1) status = ent.TaskStatus.in_progress;
    if (_selectedTab == 2) status = ent.TaskStatus.done;
    
    context.read<TaskBloc>().add(FetchTasks(status: status));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: const Color(0xFF0D8549)),
          );
          _fetchTasks();
        } else if (state is TaskError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(context),
        drawer: const AppSidebar(),
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
                    return _buildErrorState(state.message);
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.list, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        const Text(
                          'Tarik untuk memuat tugas',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchTasks,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _orange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: const Text('Refresh', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertCircle, size: 64, color: Colors.redAccent),
            const SizedBox(height: 24),
            Text(
              'Oops!',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _fetchTasks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.clipboardCheck, size: 80, color: _textSecondary.withOpacity(0.1)),
          const SizedBox(height: 20),
          Text(
            'Tidak ada tugas',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semua tugas untuk filter ini sudah selesai atau belum dibuat.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _fetchTasks,
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            label: const Text('Perbarui Data'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _orange,
              side: const BorderSide(color: _orange),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              color: const Color(0xFFEFFBF5),
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
    final isCompleted = task.status == ent.TaskStatus.done;
    final isOverdue = task.dueDate != null && task.dueDate!.isBefore(DateTime.now()) && !isCompleted;

    return GestureDetector(
      onTap: () => context.pushNamed(kRouteRoutePlanner, extra: task),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
          ],
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
                      PopupMenuButton<String>(
                        icon: const Icon(LucideIcons.moreVertical, size: 18, color: Color(0xFF6B7280)),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await context.pushNamed(kRouteNewTask, extra: task);
                            _fetchTasks();
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Text('Hapus Tugas?'),
                                content: Text('Apakah Anda yakin ingin menghapus "${task.title}"? Tindakan ini tidak dapat dibatalkan.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              context.read<TaskBloc>().add(DeleteTask(task.id));
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(LucideIcons.pencil, size: 16, color: Color(0xFF0D8549)),
                                SizedBox(width: 12),
                                Text('Edit Tugas'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                                SizedBox(width: 12),
                                Text('Hapus Tugas', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.description,
                    style: const TextStyle(color: _textSecondary, fontSize: 13),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
