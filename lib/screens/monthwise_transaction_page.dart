import 'package:thereadtrans/models/bnk_transaction.dart';
import 'package:thereadtrans/utils/database_helper.dart';
import 'package:thereadtrans/utils/values.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class MonthWiseTransactionPage extends StatefulWidget {
  final String bnkName;

  MonthWiseTransactionPage(this.bnkName);

  @override
  State<StatefulWidget> createState() => MonthWiseTransactionPageState(bnkName);
}

class MonthWiseTransactionPageState extends State<MonthWiseTransactionPage> {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _loading = true;

  List<BnkTransaction>? transactionList;
  int? count;

  Future<void> updateList() async {
    final Future<Database> dbFuture = _databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<BnkTransaction>> bnkTransactionListFuture =
      _databaseHelper.getBnkTransactionListPerBank(bnkName);
      bnkTransactionListFuture.then((bnkTransactionList) {
        setState(() {
          transactionList = bnkTransactionList;
          count = bnkTransactionList.length;
          _loading = false;
        });
      });
    });
  }

  String bnkName;

  MonthWiseTransactionPageState(this.bnkName);

  @override
  Widget build(BuildContext context) {
    if (transactionList == null) {
      transactionList = [];
      updateList();
    }

    Size size = MediaQuery.of(context).size;
    double height = size.height / 8;
    double width = size.width;

    double aspectRatio = width / height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          color: Colors.teal[700],
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: _screenWidget(aspectRatio),
      ),
    );
  }

  Widget _screenWidget(double aspectRatio) {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
        child: GridView.count(
          crossAxisCount: 1,
          childAspectRatio: aspectRatio,
          children: transactionList!.map((BnkTransaction item) {
            return _listItem(item);
          }).toList(growable: false),
        ));
  }

  Widget _listItem(BnkTransaction item) {
    return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.teal[700]!,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _itemMonth(monthMap[item.month]!),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _itemDebitedAmt(item.debitedAmt),
                    _itemCreditedAmt(item.creditedAmt)
                  ],
                )
              ],
            )));
  }

  Widget _itemMonth(String month) {
    return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
        child: Text(
          month,
          style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Colors.teal[900]),
        ));
  }

  Widget _itemDebitedAmt(double amount) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
      child: Text(
        'Debited : $amount',
        style: TextStyle(color: Colors.teal[800], fontSize: 15.0),
      ),
    );
  }

  Widget _itemCreditedAmt(double amount) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
      child: Text(
        'Credited : $amount',
        style: TextStyle(color: Colors.teal[800], fontSize: 15.0),
      ),
    );
  }
}
