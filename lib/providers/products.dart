import 'package:flutter/material.dart';
import '../models/http_exception.dart';
import 'dart:convert';
import 'product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavorites = false;
  final String token;
  final String userId;

  Products(this.token, this.userId, this._items);

  List<Product> get items {
    // if (_showFavorites)
    //   return _items.where((element) => element.isFavorite).toList();
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Future<void> fetchProduct([bool filterByUser= false]) async {
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://flutter-course-27722-default-rtdb.firebaseio.com/products.json?auth=$token&$filterString');
    try {
      final response = await http.get(url);
      final fetchData = json.decode(response.body) as Map<String, dynamic>;
      if (fetchData == null) return;
      url = Uri.parse(
          'https://flutter-course-27722-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$token');
      final favoritesResponse = await http.get(url);
      final favoriteData = json.decode(favoritesResponse.body);
      List<Product> _loadedProduct = [];
      fetchData.forEach((proId, proData) {
        _loadedProduct.add(Product(
            id: proId,
            title: proData['title'],
            description: proData['description'],
            price: proData['price'],
            imageUrl: proData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[proId] ?? false));
      });
      _items = _loadedProduct;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Product findById(String id) {
    return _items.firstWhere(
      (pro) => pro.id == id,
      orElse: () => null,
    );
  }

  Future<void> addProduct(Product product) async {
    var url = Uri.parse(
        'https://flutter-course-27722-default-rtdb.firebaseio.com/products.json?auth=$token');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'id': product.id,
            'creatorId': userId,
          }));
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      print('add product');
      // _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      print('Catch error');
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final proIndex = _items.indexWhere((element) => element.id == id);
    if (proIndex >= 0) {
      var url = Uri.parse(
          'https://flutter-course-27722-default-rtdb.firebaseio.com/products/$id.json');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'price': newProduct.price,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl
          }));
      _items[proIndex] = newProduct;
      notifyListeners();
    } else
      print('...');
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://flutter-course-27722-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
    final existedProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existedProduct = _items[existedProductIndex];
    _items.removeAt(existedProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existedProductIndex, existedProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existedProduct = null;
  }
// void showFavoritesOnly() {
//   _showFavorites = true;
//   notifyListeners();
// }
//
// void showAll() {
//   _showFavorites = false;
//   notifyListeners();
// }
}
