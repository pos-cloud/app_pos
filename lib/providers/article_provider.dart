import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/services/article_service.dart';
import 'package:app_pos/models/article.dart';

class ArticleNotifier extends StateNotifier<List<Article>> {
  final ArticleService _articleService;

  ArticleNotifier(this._articleService) : super([]);

  Future<void> loadArticles() async {
    try {
      final articles = await _articleService.getArticles();
      state = articles;
    } catch (e) {
      state = [];
    }
  }

  Future<void> searchArticles(String query) async {
    try {
      // Llamamos a `getArticles` con el filtro opcional
      state = [];
      final articles = await _articleService.getArticles(searchQuery: query);
      state = articles;
    } catch (e) {
      print('Error al cargar searchArticle: $e');
      state = []; // Manejo de errores: dejamos la lista vacía
    }
  }
}

final articlesProvider = StateNotifierProvider<ArticleNotifier, List<Article>>(
  (ref) => ArticleNotifier(ArticleService()),
);
