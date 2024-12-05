import 'package:app_pos/providers/global_transaction_provider.dart';
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
            padding: const EdgeInsets.only(bottom: 1),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar artículo...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.center_focus_strong),
                  tooltip: 'Escanear código de barras',
                  padding: const EdgeInsets.all(0),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                  tooltip: 'Buscar artículo',
                  padding: const EdgeInsets.all(0),
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
                      return Container(
                        margin: const EdgeInsets.only(
                            bottom: 4), // Márgenes más pequeños
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.grey.shade300, width: 0.5),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 0), // Ajustamos el padding
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: article.picture != null
                                ? Image.network(
                                    article.picture!,
                                    width: 40, // Reducir el tamaño de la imagen
                                    height: 40,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image),
                                  ),
                          ),
                          title: Row(
                            children: [
                              // Descripción del artículo (más grande y más cerca de la foto)
                              Expanded(
                                child: Text(
                                  article.posDescription ?? 'Sin descripción',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize:
                                          14), // Mantener texto más pequeño
                                ),
                              ),
                            ],
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.only(
                                right: 8.0), // Ajuste en el precio
                            child: Text(
                              '\$${article.salePrice?.toStringAsFixed(2) ?? "N/A"}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          onTap: () {
                            // Llama al método `addArticleMovement` del provider
                            ref
                                .read(globalTransactionProvider.notifier)
                                .addArticleMovement(article);
                            // Muestra un SnackBar para confirmar la acción
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Artículo "${article.description}" añadido a la transacción.'),
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
    );
  }
}
