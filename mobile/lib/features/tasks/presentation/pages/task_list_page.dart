import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/task.dart' as ent;

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  int _selectedTab = 0;
  final List<String> _tabs = ['On Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() {
    final authState = context.read<AuthBloc>().state;
    String? salesId;
    if (authState is Authenticated && authState.user.role == 'sales') {
      salesId = authState.user.id;
    }

    context.read<TaskBloc>().add(FetchTasks(status: null, salesId: salesId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message), 
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          _fetchTasks();
        } else if (state is TaskError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message), 
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const AppSidebar(),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          onPressed: () {
            context.pushNamed(kRouteNewTask).then((_) => _fetchTasks());
          },
          icon: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
          label: const Text('Add Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
        ),
        body: Column(
          children: [
            _buildPremiumHeader(),
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  } else if (state is TasksLoaded) {
                    List<ent.Task> displayTasks = state.tasks;
                    if (_selectedTab == 0) {
                      displayTasks = displayTasks.where((t) => t.status != ent.TaskStatus.done).toList();
                    } else {
                      displayTasks = displayTasks.where((t) => t.status == ent.TaskStatus.done).toList();
                    }

                    if (displayTasks.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildTaskList(displayTasks);
                  } else if (state is TaskError) {
                    return _buildErrorState(state.message);
                  }
                  return _buildInitialState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: const Icon(LucideIcons.menu, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  const Text(
                    'Visit Planning',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: _fetchTasks,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.refreshCw, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildTabBar(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
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
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected ? [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                    ] : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.clipboardList, size: 64, color: AppColors.textPlaceholder.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Tap to load your schedule', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchTasks,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Fetch Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, size: 64, color: Color(0xFFFCA5A5)),
            const SizedBox(height: 24),
            const Text('Oops!', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _fetchTasks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Try Again', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
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
          Icon(LucideIcons.checkCircle, size: 80, color: AppColors.primary.withOpacity(0.1)),
          const SizedBox(height: 24),
          const Text('No plans found', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Your visit schedule for this filter is clear.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _fetchTasks,
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            label: const Text('Refresh Data', style: TextStyle(fontWeight: FontWeight.w900)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<ent.Task> tasks) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
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
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isCompleted ? AppColors.primary : const Color(0xFFCBD5E1), width: 2),
                ),
                child: isCompleted ? const Icon(LucideIcons.check, size: 16, color: Colors.white) : null,
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
                            color: isCompleted ? AppColors.textPlaceholder : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      _buildTaskMenu(task),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.description,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(isOverdue ? LucideIcons.alertCircle : LucideIcons.calendar,
                             size: 14, color: isOverdue ? const Color(0xFFEF4444) : AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          task.dueDate != null ? DateFormat('MMM d, HH:mm').format(task.dueDate!) : 'No Deadline',
                          style: TextStyle(
                            color: isOverdue ? const Color(0xFFEF4444) : AppColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (task.customerName != null) ...[
                          const SizedBox(width: 16),
                          const Icon(LucideIcons.building, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              task.customerName!,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w900),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskMenu(ent.Task task) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(LucideIcons.moreHorizontal, size: 20, color: AppColors.textPlaceholder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) async {
        if (value == 'edit') {
          await context.pushNamed(kRouteNewTask, extra: task);
          _fetchTasks();
        } else if (value == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Delete Plan?', style: TextStyle(fontWeight: FontWeight.w900)),
              content: Text('Are you sure you want to delete "${task.title}"?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Delete'),
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
              Icon(LucideIcons.edit2, size: 16, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Edit Plan', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(LucideIcons.trash2, size: 16, color: Color(0xFFEF4444)),
              SizedBox(width: 12),
              Text('Delete Plan', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}
