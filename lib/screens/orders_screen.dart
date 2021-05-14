import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName='/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading=false;
  @override
  void initState() {
    Future.delayed(Duration.zero).then((_)async{
      setState(() {
        _isLoading=true;
      });
    await Provider.of<Orders>(context,listen: false).fetchOrder();
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context).orders;
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      drawer: AppDrawer(),
      body:_isLoading?Center(child: CircularProgressIndicator()): ListView.builder(
        itemCount: orderData.length,
        itemBuilder: (ctx, i) => OrderItem(orderData[i]),
      ),
    );
  }
}
