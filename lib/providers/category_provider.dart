import 'package:app_pos/models/category.dart';
import 'package:app_pos/services/category_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryNotifier extends StateNotifier<List<Category>> {
  final CategoryService _categoryService;

  CategoryNotifier(this._categoryService) : super([]);

  Future<void> loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      state = categories;
    } catch (e) {
      print('Error al cargar categorías: $e');
      state = [];
    }
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<Category>>(
  (ref) => CategoryNotifier(CategoryService()),
);
