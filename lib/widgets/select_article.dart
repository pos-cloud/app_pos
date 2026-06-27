import 'package:app_pos/utils/app_number_format.dart';
import 'dart:async';
import 'package:app_pos/models/article.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/screens/barcode_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/providers/article_provider.dart';

class SelectArticleWidget extends ConsumerStatefulWidget {
  const SelectArticleWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<SelectArticleWidget> createState() =>
      _SelectArticleWidgetState();
}

class _SelectArticleWidgetState extends ConsumerState<SelectArticleWidget> {
  late final _Debouncer _debouncer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _debouncer = _Debouncer(milliseconds: 500);
  }

  @override
  void dispose() {
    _debouncer._timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _addArticleToTransaction(Article article) {
    ref.read(globalTransactionProvider.notifier).addMovementOfArticle(article);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Artículo "${article.description}" añadido a la transacción.'),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _scanBarcode() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const BarcodeScannerScreen(),
      ),
    );

    if (code == null || code.trim().isEmpty || !mounted) return;

    // Vuelca la lectura en el buscador y filtra.
    _searchController.text = code;
    final notifier = ref.read(articlesProvider.notifier);
    notifier.searchArticles(code);

    final matches = ref.read(articlesProvider);
    if (matches.length == 1) {
      _addArticleToTransaction(matches.first);
    } else if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontró un producto con el código $code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    controller: _searchController,
                    onChanged: (text) {
                      _debouncer.run(() {
                        // Llama al método de búsqueda en el provider
                        ref
                            .read(articlesProvider.notifier)
                            .searchArticles(text);
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _scanBarcode,
                  icon: const Icon(Icons.center_focus_strong),
                  tooltip: 'Escanear código de barras',
                  padding: const EdgeInsets.all(0),
                ),
              ],
            ),
          ),
          // Aquí envolvemos el ListView.builder en un Expanded
          Expanded(
            child: articles.isEmpty
                ? const Center(child: CircularProgressIndicator())
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
                              vertical: 6.0, horizontal: 0),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: (isValidUrl(article.picture))
                                ? Image.network(
                                    article.picture,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.grey.shade300,
                                        child: const Icon(Icons.broken_image),
                                      );
                                    },
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
                              Expanded(
                                child: Text(
                                  article.posDescription,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              article.salePrice.asMoney,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          onTap: () => _addArticleToTransaction(article),
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

class _Debouncer {
  _Debouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

bool isValidUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null &&
      uri.hasAbsolutePath &&
      (url.startsWith('http://') || url.startsWith('https://'));
}
