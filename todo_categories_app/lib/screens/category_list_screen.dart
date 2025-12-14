import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';
import '../widgets/category_card.dart';
import 'category_detail_screen.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  void _showCategoryDialog(
    BuildContext context, {
    String? categoryId,
    String? initialName,
  }) {
    final controller = TextEditingController(text: initialName ?? '');

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            categoryId == null ? 'Nueva Categoría' : 'Editar Categoría',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Nombre de la categoría',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                final provider =
                    Provider.of<TodoProvider>(context, listen: false);

                if (categoryId == null) {
                  provider.addCategory(name);
                } else {
                  provider.updateCategory(categoryId, name);
                }

                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteCategory(BuildContext context, String categoryId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Eliminar categoría',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          '¿Estás seguro de eliminar esta categoría y todos sus Todos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Provider.of<TodoProvider>(context, listen: false)
                  .deleteCategory(categoryId);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);
    final categories = provider.categories;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ Para que el header morado (del main.dart) se vea detrás
      extendBodyBehindAppBar: true,

      // ✅ Opción A: AppBar SIN título (evita el duplicado)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
                maxHeight: 420,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE7EAF2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Título SOLO aquí (en la tarjeta)
                    Text(
                      'Lista de Todos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1F2430),
                          ),
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: categories.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay categorías aún. Agrega una con el botón +',
                              ),
                            )
                          : ListView.separated(
                              // ✅ espacio para que el FAB no tape items
                              padding: const EdgeInsets.only(bottom: 120),
                              itemCount: categories.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (ctx, index) {
                                final category = categories[index];

                                return CategoryCard(
                                  category: category,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CategoryDetailScreen(
                                          categoryId: category.id,
                                        ),
                                      ),
                                    );
                                  },
                                  onEdit: () {
                                    _showCategoryDialog(
                                      context,
                                      categoryId: category.id,
                                      initialName: category.name,
                                    );
                                  },
                                  onDelete: () {
                                    _confirmDeleteCategory(
                                      context,
                                      category.id,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
