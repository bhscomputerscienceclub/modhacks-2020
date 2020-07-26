import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:convert';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/database.dart';

Future<OneFood> fetchOneFood(String barcode) async {
  if (int.parse(barcode) <= 0) {
    throw Exception('Scanning Error, Try Again');
  }
  Map<String, String> requestHeaders = {
    "x-app-id": "b5bc0386",
    "x-app-key": "04b325ce58366ad94a40bd147bbf491a",
  };
  print('get');
  final response = await http.get(
    'https://trackapi.nutritionix.com/v2/search/item?&upc=' + barcode,
    headers: requestHeaders,
  );
  print(response);
  print(response.statusCode);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return OneFood.fromJson(json.decode(response.body), true);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    return OneFood.fromJson(json.decode('{"works":false}'), false);
  }
}

class QrCodeScan extends StatefulWidget {
  @override
  _QrCodeScanState createState() => _QrCodeScanState();
}

class _QrCodeScanState extends State<QrCodeScan> {
  String _scanBarcode = 'Unknown';
  String _foodName = 'Unknown';
  DatabaseHelper helper = DatabaseHelper();
  @override
  void initState() {
    super.initState();
    runBarcodeThing();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
    getFoodName();
  }

  Future<OneFood> food;

  Future<void> getFoodName() async {
    String foodout;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      food = fetchOneFood(_scanBarcode);
      print('got food');
      print((await food));
      foodout = (await food).label;
    } on PlatformException {
      foodout = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _foodName = foodout;
    });
  }

  Future<void> runBarcodeThing() async {
    scanBarcodeNormal();
  }

  Future<void> addFood() async {
    helper.insertOneFood(await food);
    exitscreen(true);
  }

  void exitscreen(bool reload) {
    Navigator.pop(context, reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Add Food')),
        body: Builder(builder: (BuildContext context) {
          return Container(
              alignment: Alignment.center,
              child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Card(
                      child: ListTile(
                        title: Text('Scanned Barcode Value'),
                        subtitle: Text(_scanBarcode),
                        leading: new Icon(MdiIcons.barcodeScan, size: 50.0),
                      ),
                    ),
                    FutureBuilder<OneFood>(
                      future: food,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          print(snapshot.data.works);
                          if (snapshot.data.works) {
                            return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Card(
                                    child: ListTile(
                                      title: Text(snapshot.data.label),
                                      subtitle: Text(
                                        '${(snapshot.data.calories).toStringAsFixed(2)} kcal per serving',
                                      ),
                                      trailing:
                                          new Icon(MdiIcons.food, size: 50.0),
                                    ),
                                  ),
                                  Card(
                                    child: ListTile(
                                      title: Text((() {
                                            if (snapshot.data.servingConsumed ==
                                                1) {
                                              return 'serving (';
                                            } else {
                                              return 'servings (';
                                            }
                                          }()) +
                                          '${(snapshot.data.servingQty).toStringAsFixed(2)} ${snapshot.data.servingUnit})'),
                                      subtitle: Text(
                                          '${(snapshot.data.calories * snapshot.data.servingConsumed).toString()} Calories'),
                                      leading: Container(
                                          width: 40,
                                          child: OutlineButton(
                                            borderSide: BorderSide(
                                                width: 2,
                                                color: Colors.blueGrey),
                                            onPressed: () =>
                                                showMaterialNumberPicker(
                                              context: context,
                                              title: "Number of Servings",
                                              maxNumber: 20,
                                              minNumber: 1,
                                              selectedNumber:
                                                  snapshot.data.servingConsumed,
                                              onChanged: (value) => setState(
                                                  () => snapshot.data
                                                      .servingConsumed = value),
                                            ),
                                            child: Text(snapshot
                                                .data.servingConsumed
                                                .toString()),
                                          )),
                                    ),
                                  ),
                                  ButtonBar(
                                    children: [
                                      FlatButton(
                                        onPressed: () => exitscreen(false),
                                        child: Text("Go Back"),
                                      ),
                                      RaisedButton(
                                        onPressed: () => addFood(),
                                        child: Text("Add To Total"),
                                      ),
                                    ],
                                    alignment: MainAxisAlignment.center,
                                  )
                                ]);
                          } else {
                            return Column(children: [
                              Text("Food Not Found or an error occured"),
                              ButtonBar(
                                children: [
                                  FlatButton(
                                    onPressed: () => exitscreen(false),
                                    child: Text("Go Back"),
                                  ),
                                  RaisedButton(
                                      onPressed: () => runBarcodeThing(),
                                      child: Text("Retry Scan")),
                                ],
                                alignment: MainAxisAlignment.center,
                              )
                            ]);
                          }
                        } else if (snapshot.hasError) {
                          return Column(children: [
                            Text("${snapshot.error}"),
                            ButtonBar(
                              children: [
                                FlatButton(
                                  onPressed: () => exitscreen(false),
                                  child: Text("Go Back"),
                                ),
                                RaisedButton(
                                    onPressed: () => runBarcodeThing(),
                                    child: Text("Retry Scan")),
                              ],
                              alignment: MainAxisAlignment.center,
                            )
                          ]);
                        }

                        return CircularProgressIndicator();
                      },
                    ),
                  ]));
        }));
  }
}
