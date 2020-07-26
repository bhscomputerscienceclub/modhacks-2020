import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:convert';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/database.dart';
import 'package:my_app/screens/second_page.dart';

///fetchonefood import from page2

class ManualActivity extends StatefulWidget {
  @override
  _ManualActivityState createState() => _ManualActivityState();
}

class _ManualActivityState extends State<ManualActivity> {
  String _foodName = 'Unknown';
  DatabaseHelper helper = DatabaseHelper();
  @override
  void initState() {
    super.initState();
  }

  OneFood food;

  Future<void> addFood() async {
    helper.insertOneFood(await food);
    exitscreen(true);
  }

  void exitscreen(bool reload) {
    Navigator.pop(context, reload);
  }

  final _formKey = GlobalKey<FormState>();
  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  double calories;
  String name;
  Widget getForm() {
    Form form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(0),
            child: Card(
                child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Name',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter something';
                      }

                      return null;
                    },
                    onSaved: (val) => setState(() => name = val),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Cal',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter something';
                      }
                      if (!isNumeric(value)) {
                        return 'Please enter numbers only';
                      }

                      return null;
                    },
                    onSaved: (val) =>
                        setState(() => calories = double.parse(val)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ButtonBar(
                    children: [
                      FlatButton(
                        onPressed: () => exitscreen(false),
                        child: Text("Go Back"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          final form = _formKey.currentState;
                          if (form.validate()) {
                            _showDialog(context);
                            form.save();
                            print(calories);
                            food = OneFood(
                              calories: calories,
                              label: name,
                              works: true,
                            );
                            addFood();
                          }
                        },
                        child: Text("Add To Total"),
                      ),
                    ],
                    alignment: MainAxisAlignment.center,
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
    return form;
  }

  _showDialog(BuildContext context) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text('Processing Data')));
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: const Text('Add Manual Activity')),
            body: Builder(builder: (BuildContext context) {
              return Container(
                  alignment: Alignment.center,
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: getForm(),
                        )
                      ]));
            }));
  }
}
