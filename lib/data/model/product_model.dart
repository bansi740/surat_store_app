class ProductModel {
  String? pId;
  String name;
  String description;
  double price;
  int stockQty;
  String imagePath;
  int isSynced;

  ProductModel({
    this.pId,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQty,
    required this.imagePath,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'p_id': pId,
      'name': name,
      'description': description,
      'price': price,
      'stock_qty': stockQty,
      'image_path': imagePath,
      'is_synced': isSynced,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      pId: map['p_id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      stockQty: map['stock_qty'],
      imagePath: map['image_path'],
      isSynced: map['is_synced'],
    );
  }
}