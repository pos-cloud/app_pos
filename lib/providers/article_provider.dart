import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/services/article_service.dart';
import 'package:app_pos/models/article.dart';

class ArticleNotifier extends StateNotifier<List<Article>> {
  final ArticleService _articleService;
  List<Article> _allArticles = [];

  ArticleNotifier(this._articleService) : super([]);

  /// [makeIds]: IDs de marcas del usuario (`user.makes`); si es null o vacío, no se filtra por marca.
  Future<void> loadArticles({List<String>? makeIds}) async {
    try {
      final articles = await _articleService.getArticles(makeIds: makeIds);
      _allArticles = articles;
      state = articles;
    } catch (e) {
      _allArticles = [];
      state = [];
    }
  }

  Future<Article> updateArticle(Article article) async {
    final updated = await _articleService.updateArticle(article);
    _allArticles =
        _allArticles.map((a) => a.id == updated.id ? updated : a).toList();
    state = state.map((a) => a.id == updated.id ? updated : a).toList();
    return updated;
  }

  void searchArticles(String query) {
    if (query.trim().isEmpty) {
      state = List.from(_allArticles);
      return;
    }
    final lowerQuery = query.toLowerCase().trim();
    state = _allArticles.where((article) {
      final desc = (article.description).toLowerCase();
      final posDesc = (article.posDescription).toLowerCase();
      final code = (article.code ?? '').toLowerCase();
      final barcode = (article.barcode ?? '').toLowerCase();
      return desc.contains(lowerQuery) ||
          posDesc.contains(lowerQuery) ||
          code.contains(lowerQuery) ||
          barcode.contains(lowerQuery);
    }).toList();
  }
}

final articlesProvider = StateNotifierProvider<ArticleNotifier, List<Article>>(
  (ref) => ArticleNotifier(ArticleService()),
);
