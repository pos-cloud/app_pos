import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/providers/article_provider.dart';

class SelectArticleWidget extends ConsumerWidget {
  const SelectArticleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(articlesProvider);

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar artículo...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.center_focus_strong),
                  tooltip: 'Escanear código de barras',
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                  tooltip: 'Buscar artículo',
                ),
              ],
            ),
          ),
          // Aquí envolvemos el ListView.builder en un Expanded
          Expanded(
            child: articles.isEmpty
                ? const Center(child: Text('No se encontraron artículos'))
                : ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8.0),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              article.posDescription ?? 'Sin descripción',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              '\$${article.salePrice?.toStringAsFixed(2) ?? "N/A"}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
