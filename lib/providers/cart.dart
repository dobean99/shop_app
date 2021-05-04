import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

// get number of Items
  int get countItems {
    return _items.length;
  }

// get total amount
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity * cartItem.price;
    });
    return total;
  }

  void addItem(String productId, String title, double price) {
    if (_items.containsKey(productId)) {
      //change quantity
      _items.update(
          productId,
          (exitedItem) => CartItem(
                id: exitedItem.id,
                title: exitedItem.title,
                price: exitedItem.price,
                quantity: exitedItem.quantity + 1,
              ));
    } else {
      //add item
      _items.putIfAbsent(
          productId,
          () => CartItem(
                id: DateTime.now().toString(),
                title: title,
                price: price,
                quantity: 1,
              ));
    }
    notifyListeners();
  }
  void removeItem(String productId)
  {
    _items.remove(productId);
    notifyListeners();
  }
  void clearItem()
  {
    _items={};
    notifyListeners();
  }
}
