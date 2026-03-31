bool _bool(Map<String, dynamic>? m, String key) {
  if (m == null) return false;
  final v = m[key];
  return v is bool ? v : false;
}

Map<String, dynamic>? _map(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return null;
}

/// IDs de tipos de transacción permitidos: strings, `{\$oid}`, o documento con `_id`.
List<String> _parseObjectIdList(dynamic raw) {
  final out = <String>[];
  if (raw is! List) return out;
  for (final e in raw) {
    final id = _parseObjectIdString(e);
    if (id != null && id.isNotEmpty) {
      out.add(id);
    }
  }
  return out;
}

String? _parseObjectIdString(dynamic e) {
  if (e == null) return null;
  if (e is String) {
    final t = e.trim();
    return t.isEmpty ? null : t;
  }
  if (e is Map) {
    final m = Map<String, dynamic>.from(e);
    final oid = m[r'$oid'] ?? m['oid'] ?? m['_id'];
    if (oid != null) {
      final t = oid.toString().trim();
      return t.isEmpty ? null : t;
    }
  }
  return null;
}

/// Permisos del usuario (login `user.permission`).
class Permission {
  final String id;
  final String name;
  final PermissionCollections collections;
  final PermissionMenu menu;
  final bool filterTransaction;
  final bool filterCompany;
  /// Mismo concepto que `user.makes`: array de ids (string / ObjectId en JSON).
  final List<String> transactionTypeIds;
  final bool editArticle;
  final bool allowDiscount;

  Permission({
    required this.id,
    required this.name,
    required this.collections,
    required this.menu,
    required this.filterTransaction,
    required this.filterCompany,
    required this.transactionTypeIds,
    required this.editArticle,
    required this.allowDiscount,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      collections: PermissionCollections.fromJson(_map(json['collections'])),
      menu: PermissionMenu.fromJson(_map(json['menu'])),
      filterTransaction: _bool(json, 'filterTransaction'),
      filterCompany: _bool(json, 'filterCompany'),
      transactionTypeIds: _parseObjectIdList(json['transactionTypes']),
      editArticle: _bool(json, 'editArticle'),
      allowDiscount: _bool(json, 'allowDiscount'),
    );
  }
}

class PermissionCollections {
  final PermissionCrudExport transactions;
  final PermissionArticles articles;
  final PermissionCrudExport companies;
  final PermissionMovementsOfArticles movementsOfArticles;
  final PermissionBoxes boxes;

  PermissionCollections({
    required this.transactions,
    required this.articles,
    required this.companies,
    required this.movementsOfArticles,
    required this.boxes,
  });

  factory PermissionCollections.fromJson(Map<String, dynamic>? json) {
    final j = json ?? {};
    return PermissionCollections(
      transactions: PermissionCrudExport.fromJson(_map(j['transactions'])),
      articles: PermissionArticles.fromJson(_map(j['articles'])),
      companies: PermissionCrudExport.fromJson(_map(j['companies'])),
      movementsOfArticles:
          PermissionMovementsOfArticles.fromJson(_map(j['movementsOfArticles'])),
      boxes: PermissionBoxes.fromJson(_map(j['boxes'])),
    );
  }
}

class PermissionCrudExport {
  final bool add;
  final bool edit;
  final bool delete;
  final bool export;

  PermissionCrudExport({
    required this.add,
    required this.edit,
    required this.delete,
    required this.export,
  });

  factory PermissionCrudExport.fromJson(Map<String, dynamic>? json) {
    final j = json ?? {};
    return PermissionCrudExport(
      add: _bool(j, 'add'),
      edit: _bool(j, 'edit'),
      delete: _bool(j, 'delete'),
      export: _bool(j, 'export'),
    );
  }
}

class PermissionArticles {
  final bool add;
  final bool edit;
  final bool delete;
  final bool export;
  final bool printLabel;
  final bool copy;
  final bool import;
  final bool printLabels;
  final bool updatePrices;
  final bool printPriceList;

  PermissionArticles({
    required this.add,
    required this.edit,
    required this.delete,
    required this.export,
    required this.printLabel,
    required this.copy,
    required this.import,
    required this.printLabels,
    required this.updatePrices,
    required this.printPriceList,
  });

  factory PermissionArticles.fromJson(Map<String, dynamic>? json) {
    final j = json ?? {};
    return PermissionArticles(
      add: _bool(j, 'add'),
      edit: _bool(j, 'edit'),
      delete: _bool(j, 'delete'),
      export: _bool(j, 'export'),
      printLabel: _bool(j, 'printLabel'),
      copy: _bool(j, 'copy'),
      import: _bool(j, 'import'),
      printLabels: _bool(j, 'printLabels'),
      updatePrices: _bool(j, 'updatePrices'),
      printPriceList: _bool(j, 'printPriceList'),
    );
  }
}

class PermissionMovementsOfArticles {
  final bool edit;
  final bool delete;
  final bool export;
  final bool updatePrice;
  final bool updateDiscount;

  PermissionMovementsOfArticles({
    required this.edit,
    required this.delete,
    required this.export,
    required this.updatePrice,
    required this.updateDiscount,
  });

  factory PermissionMovementsOfArticles.fromJson(Map<String, dynamic>? json) {
    final j = json ?? {};
    return PermissionMovementsOfArticles(
      edit: _bool(j, 'edit'),
      delete: _bool(j, 'delete'),
      export: _bool(j, 'export'),
      updatePrice: _bool(j, 'updatePrice'),
      updateDiscount: _bool(j, 'updateDiscount'),
    );
  }
}

class PermissionBoxes {
  final bool print;

  PermissionBoxes({required this.print});

  factory PermissionBoxes.fromJson(Map<String, dynamic>? json) {
    final j = json ?? {};
    return PermissionBoxes(print: _bool(j, 'print'));
  }
}

class PermissionMenu {
  final PermissionMenuSales sales;
  final bool money;
  final bool production;
  final bool purchases;
  final bool stock;
  final bool articles;
  final PermissionMenuCompanies companies;
  final bool report;
  final bool config;
  final bool gallery;
  final bool resto;

  PermissionMenu({
    required this.sales,
    required this.money,
    required this.production,
    required this.purchases,
    required this.stock,
    required this.articles,
    required this.companies,
    required this.report,
    required this.config,
    required this.gallery,
    required this.resto,
  });

  factory PermissionMenu.fromJson(Map<String, dynamic>? json) {
    final j = json ?? {};
    return PermissionMenu(
      sales: PermissionMenuSales.fromJson(_map(j['sales'])),
      money: _bool(j, 'money'),
      production: _bool(j, 'production'),
      purchases: _bool(j, 'purchases'),
      stock: _bool(j, 'stock'),
      articles: _bool(j, 'articles'),
      companies: PermissionMenuCompanies.fromJson(_map(j['companies'])),
      report: _bool(j, 'report'),
      config: _bool(j, 'config'),
      gallery: _bool(j, 'gallery'),
      resto: _bool(j, 'resto'),
    );
  }
}

class PermissionMenuSales {
  final bool counter;
  final bool tiendaNube;
  final bool wooCommerce;
  final bool delivery;
  final bool voucherReader;
  final bool resto;
  final bool subscription;

  PermissionMenuSales({
    required this.counter,
    required this.tiendaNube,
    required this.wooCommerce,
    required this.delivery,
    required this.voucherReader,
    required this.resto,
    required this.subscription,
  });

  factory PermissionMenuSales.fromJson(Map<String, dynamic>? json) {
    final j = json ?? {};
    return PermissionMenuSales(
      counter: _bool(j, 'counter'),
      tiendaNube: _bool(j, 'tiendaNube'),
      wooCommerce: _bool(j, 'wooCommerce'),
      delivery: _bool(j, 'delivery'),
      voucherReader: _bool(j, 'voucherReader'),
      resto: _bool(j, 'resto'),
      subscription: _bool(j, 'subscription'),
    );
  }
}

class PermissionMenuCompanies {
  final bool client;
  final bool provider;
  final bool group;

  PermissionMenuCompanies({
    required this.client,
    required this.provider,
    required this.group,
  });

  factory PermissionMenuCompanies.fromJson(Map<String, dynamic>? json) {
    final j = json ?? {};
    return PermissionMenuCompanies(
      client: _bool(j, 'client'),
      provider: _bool(j, 'provider'),
      group: _bool(j, 'group'),
    );
  }
}
