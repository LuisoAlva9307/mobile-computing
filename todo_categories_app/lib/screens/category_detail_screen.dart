import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';
import '../models/todo_category.dart';
import '../models/todo_item.dart';
import '../widgets/todo_list_tile.dart';

enum TodoFilter { all, pending, completed }

class CategoryDetailScreen extends StatefulWidget {
  final String categoryId;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  TodoFilter _currentFilter = TodoFilter.all;

  void _showTodoDialog(
    BuildContext context,
    TodoCategory category, {
    TodoItem? todo,
  }) {
    final isEdit = todo != null;
    final titleController = TextEditingController(text: todo?.title ?? '');
    DateTime? selectedDate = todo?.dueDate;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocalState) {
          Future<void> selectLocalDate() async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: ctx,
              initialDate: selectedDate ?? now,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 5),
            );

            if (picked != null) {
              setLocalState(() {
                selectedDate = picked;
              });
            }
          }

          return AlertDialog(
            title: Text(isEdit ? 'Editar Todo' : 'Nuevo Todo'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate == null
                              ? 'Sin fecha objetivo'
                              : 'Fecha: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                        ),
                      ),
                      TextButton(
                        onPressed: selectLocalDate,
                        child: const Text('Elegir fecha'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = titleController.text.trim();
                  if (text.isEmpty) return;

                  final provider = Provider.of<TodoProvider>(
                    context,
                    listen: false,
                  );

                  if (isEdit) {
                    provider.updateTodo(
                      category.id,
                      todo!.id,
                      title: text,
                      dueDate: selectedDate,
                    );
                  } else {
                    provider.addTodo(
                      category.id,
                      text,
                      selectedDate,
                    );
                  }

                  Navigator.of(ctx).pop();
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteTodo(
    BuildContext context,
    TodoCategory category,
    TodoItem todo,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Todo'),
        content: const Text(
          '¿Estás seguro de eliminar este Todo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<TodoProvider>(
                context,
                listen: false,
              ).deleteTodo(category.id, todo.id);

              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  List<TodoItem> _applyFilter(TodoCategory category) {
    switch (_currentFilter) {
      case TodoFilter.pending:
        return category.todos.where((t) => !t.isDone).toList();
      case TodoFilter.completed:
        return category.todos.where((t) => t.isDone).toList();
      case TodoFilter.all:
      default:
        return category.todos;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);
    final category = provider.getCategoryById(widget.categoryId);

    if (category == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Categoría no encontrada'),
        ),
        body: const Center(
          child: Text('La categoría ya no existe.'),
        ),
      );
    }

    final todos = _applyFilter(category);

    return Scaffold(
      appBar: AppBar(
        title: Text('Categoría: ${category.name}'),
      ),
      body: Column(
        children: [
          // Resumen
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Chip(
                  label: Text(
                    'Total: ${category.totalTodos}',
                  ),
                ),
                Chip(
                  label: Text(
                    'Pendientes: ${category.pendingTodos}',
                  ),
                ),
                Chip(
                  label: Text(
                    'Completados: ${category.completedTodos}',
                  ),
                ),
              ],
            ),
          ),

          // Filtros
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _currentFilter == TodoFilter.all,
                  onSelected: (_) {
                    setState(() {
                      _currentFilter = TodoFilter.all;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Pendientes'),
                  selected: _currentFilter == TodoFilter.pending,
                  onSelected: (_) {
                    setState(() {
                      _currentFilter = TodoFilter.pending;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Completados'),
                  selected: _currentFilter == TodoFilter.completed,
                  onSelected: (_) {
                    setState(() {
                      _currentFilter = TodoFilter.completed;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Lista de Todos
          Expanded(
            child: todos.isEmpty
                ? const Center(
                    child: Text(
                      'No hay Todos en esta vista.',
                    ),
                  )
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (ctx, index) {
                      final todo = todos[index];

                      return TodoListTile(
                        todo: todo,
                        onChanged: (value) {
                          Provider.of<TodoProvider>(
                            context,
                            listen: false,
                          ).updateTodo(
                            category.id,
                            todo.id,
                            isDone: value ?? false,
                          );
                        },
                        onEdit: () => _showTodoDialog(
                          context,
                          category,
                          todo: todo,
                        ),
                        onDelete: () => _confirmDeleteTodo(
                          context,
                          category,
                          todo,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTodoDialog(context, category),
        child: const Icon(Icons.add),
      ),
    );
  }
}
