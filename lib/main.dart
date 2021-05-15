import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/user_products_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/edit_product_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './screens/cart_screen.dart';
import './providers/orders.dart';
import './screens/auth_screen.dart';
import './providers/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (context) => Products(),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (context) => Orders(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.redAccent,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth() ? ProductsOverviewScreen() : AuthScreen(),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
