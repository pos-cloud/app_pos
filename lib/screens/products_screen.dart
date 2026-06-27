import 'dart:async';
import 'package:app_pos/models/article.dart';
import 'package:app_pos/providers/article_provider.dart';
import 'package:app_pos/providers/auth_provider.dart';
import 'package:app_pos/screens/edit_article_screen.dart';
import 'package:app_pos/utils/app_number_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  static const path = '/products';

  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  late final _Debouncer _debouncer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _debouncer = _Debouncer(milliseconds: 500);
    Future.microtask(_loadArticles);
  }

  Future<void> _loadArticles() async {
    final user = ref.read(authUserProvider);
    final makeIds = (user?.makes ?? [])
        .map((m) => m.id)
        .where((id) => id.isNotEmpty)
        .toList();
    final makeIdsForQuery = makeIds.isNotEmpty ? makeIds : null;

    setState(() => _isLoading = true);
    await ref
        .read(articlesProvider.notifier)
        .loadArticles(makeIds: makeIdsForQuery);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _debouncer._timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articles = ref.watch(articlesProvider);
    final canEdit =
        ref.watch(authUserProvider)?.permission?.collections.articles.edit ??
            false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                onChanged: (text) {
                  _debouncer.run(() {
                    ref.read(articlesProvider.notifier).searchArticles(text);
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar producto...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : articles.isEmpty
                      ? const Center(
                          child: Text('No se encontraron productos'),
                        )
                      : ListView.builder(
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            final article = articles[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                  horizontal: 8,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.shade100,
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                title: Text(
                                  article.description.isNotEmpty
                                      ? article.description
                                      : article.posDescription,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: _buildSubtitle(article),
                                trailing: Text(
                                  article.salePrice.asMoney,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => EditArticleScreen(
                                        article: article,
                                        canEdit: canEdit,
                                      ),
                                    ),
                                  );
                                },
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

  Widget? _buildSubtitle(Article article) {
    final parts = <String>[];
    if (article.code != null && article.code!.isNotEmpty) {
      parts.add('Cód: ${article.code}');
    }
    if (article.barcode != null && article.barcode!.isNotEmpty) {
      parts.add(article.barcode!);
    }
    if (parts.isEmpty) return null;
    return Text(
      parts.join(' · '),
      style: const TextStyle(fontSize: 12),
    );
  }
}

class _Debouncer {
  _Debouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
