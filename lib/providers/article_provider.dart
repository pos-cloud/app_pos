import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/services/article_service.dart';
import 'package:app_pos/models/article.dart';

class ArticleNotifier extends StateNotifier<List<Article>> {
  final ArticleService _articleService;

  ArticleNotifier(this._articleService) : super([]);

  Future<void> loadArticles() async {
    try {
      print("entro");
      final articles = await _articleService.getArticles();
      print(articles);
      state = articles;
    } catch (e) {
      state = [];
    }
  }
}

final articlesProvider = StateNotifierProvider<ArticleNotifier, List<Article>>(
  (ref) => ArticleNotifier(ArticleService()),
);
