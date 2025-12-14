import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryId;
  const CategoryDetailScreen({super.key, required this.categoryId});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  int _filter = 0;

  void _showNewTodoDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Nuevo Todo',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate == null
                              ? 'Sin fecha objetivo'
                              : 'Fecha: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF5A6273),
                                  ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: now,
                            firstDate: DateTime(now.year - 1),
                            lastDate: DateTime(now.year + 5),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                        child: const Text('Elegir fecha'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    Provider.of<TodoProvider>(context, listen: false).addTodo(
                      widget.categoryId,
                      title,
                      selectedDate,
                    );

                    Navigator.pop(dialogCtx);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = Provider.of<TodoProvider>(context);

    final category = provider.getCategoryById(widget.categoryId);
    final todos = category?.todos ?? [];

    final total = todos.length;
    final completed = todos.where((t) => t.isDone == true).length;
    final pending = total - completed;

    final filteredTodos = switch (_filter) {
      1 => todos.where((t) => t.isDone == false).toList(),
      2 => todos.where((t) => t.isDone == true).toList(),
      _ => todos,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Categoría: ${category?.name ?? 'Sin nombre'}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _StatChip(label: 'Total', value: total)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _StatChip(label: 'Pendientes', value: pending)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _StatChip(label: 'Completados', value: completed)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE7EAF2)),
                ),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Todos')),
                    ButtonSegment(value: 1, label: Text('Pendientes')),
                    ButtonSegment(value: 2, label: Text('Completados')),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (s) {
                    setState(() => _filter = s.first);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE7EAF2)),
                  ),
                  child: filteredTodos.isEmpty
                      ? Center(
                          child: Text(
                            _filter == 0
                                ? 'No hay Todos en esta categoría.'
                                : _filter == 1
                                    ? 'No hay Todos pendientes.'
                                    : 'No hay Todos completados.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: const Color(0xFF5A6273),
                                ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 120),
                          itemCount: filteredTodos.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (ctx, index) {
                            final todo = filteredTodos[index];

                            return _TodoTile(
                              title: todo.title,
                              isDone: todo.isDone,
                              dueDate: todo.dueDate,
                              onToggleDone: (val) {
                                provider.updateTodo(
                                  widget.categoryId,
                                  todo.id,
                                  isDone: val,
                                );
                              },
                              onEdit: () {
                                _showEditTodoDialog(
                                  context,
                                  todoId: todo.id,
                                  initialTitle: todo.title,
                                  initialDueDate: todo.dueDate,
                                );
                              },
                              onDelete: () {
                                provider.deleteTodo(widget.categoryId, todo.id);
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showNewTodoDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditTodoDialog(
    BuildContext context, {
    required String todoId,
    required String initialTitle,
    required DateTime? initialDueDate,
  }) {
    final titleController = TextEditingController(text: initialTitle);
    DateTime? selectedDate = initialDueDate;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Editar Todo',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate == null
                              ? 'Sin fecha objetivo'
                              : 'Fecha: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF5A6273),
                                  ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate ?? now,
                            firstDate: DateTime(now.year - 1),
                            lastDate: DateTime(now.year + 5),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                        child: const Text('Elegir fecha'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    Provider.of<TodoProvider>(context, listen: false)
                        .updateTodo(
                      widget.categoryId,
                      todoId,
                      title: title,
                      dueDate: selectedDate,
                    );

                    Navigator.pop(dialogCtx);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EAF2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3B4252),
                ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F0FF),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE7EAF2)),
            ),
            child: Text(
              '$value',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  final String title;
  final bool isDone;
  final DateTime? dueDate;
  final ValueChanged<bool> onToggleDone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TodoTile({
    required this.title,
    required this.isDone,
    required this.dueDate,
    required this.onToggleDone,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8F9FD),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onToggleDone(!isDone),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE7EAF2)),
          ),
          child: Row(
            children: [
              Checkbox(
                value: isDone,
                onChanged: (v) => onToggleDone(v ?? false),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                          ),
                    ),
                    if (dueDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Fecha objetivo: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF5A6273),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
