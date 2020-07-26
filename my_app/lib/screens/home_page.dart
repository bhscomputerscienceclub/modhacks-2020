import 'package:flutter/material.dart';
import 'package:my_app/screens/second_page.dart';
import 'package:my_app/database.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:my_app/screens/manual_activity.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    if (oneFoodList == null) {
      oneFoodList = List<OneFood>();
      updateListView();
    }
    debug();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(children: [
        Card(child: getCalories()),
        Expanded(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: getOneFoodListView()),
        )
      ]),
      floatingActionButton: getFAB(),
    );
  }

  bool dialVisible = true;
  Widget getFAB() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      // child: Icon(Icons.add),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(MdiIcons.barcodeScan, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () async {
            bool a = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QrCodeScan()),
            );
            if (a) {
              updateListView();
            }
          },
          label: 'Barcode Scan',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.deepOrangeAccent,
        ),
        SpeedDialChild(
          child: Icon(MdiIcons.pencilPlusOutline, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () async {
            bool a = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManualActivity()),
            );
            if (a) {
              updateListView();
            }
          },
          label: 'Manual Activity',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.green,
        ),
      ],
    );
  }

  List<bool> isSelected = [true, false, false];
  Widget getCalories() {
    print('getcalories');
    int timeinterval;
    if (isSelected[1]) {
      timeinterval = 86400;
    } else if (isSelected[2]) {
      timeinterval = 86400 * 7;
    } else if (isSelected[0]) {
      timeinterval = (86400 / 24).round();
    }
    timeinterval = timeinterval * 1000;
    int now = DateTime.now().millisecondsSinceEpoch;
    int oldest = now - timeinterval;
    double totalCalories = 0.0;
    for (var i = 0; i < this.count; i++) {
      if (this.oneFoodList[i].time > oldest) {
        totalCalories += this.oneFoodList[i].calories;
      } else {
        break;
      }
    }
    return Row(
      children: [
        Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                ),
                child: ListTile(
                  title: Text(
                    totalCalories.toStringAsFixed(2) + " Calories recorded",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Text(
                      '${(totalCalories / (2000 * timeinterval / (86400 * 1000)) * 100).toStringAsFixed(1)}% average recommended value'),
                ))),
        RotatedBox(
            quarterTurns: 1,
            child: ToggleButtons(
              color: Colors.blueAccent,
              splashColor: Colors.transparent,
              constraints: BoxConstraints(
                minWidth: 40.0, //actually height because rotate
                maxWidth: 100,
                minHeight: 40.0, //actually width
                maxHeight: 100,
              ),
              children: <Widget>[
                RotatedBox(quarterTurns: 3, child: Text('Hour')),
                RotatedBox(quarterTurns: 3, child: Text('Day')),
                RotatedBox(quarterTurns: 3, child: Text('Week')),
              ],
              isSelected: isSelected,
              onPressed: (int index) {
                setState(() {
                  for (int indexBtn = 0;
                      indexBtn < isSelected.length;
                      indexBtn++) {
                    if (indexBtn == index) {
                      isSelected[indexBtn] = true;
                    } else {
                      isSelected[indexBtn] = false;
                    }
                  }
                });
              },
            )),
      ],
    );
  }

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<OneFood> oneFoodList;
  int count = 0;

  void debug() async {
    print((await databaseHelper.getCount()).toString());
  }

  ListView getOneFoodListView() {
    print('getlistview');
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber,
              child: Center(
                  child: Text(getFirstLetter(this.oneFoodList[position].label),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ))),
            ),
            title: Text(this.oneFoodList[position].label,
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle:
                Text(this.oneFoodList[position].calories.toStringAsFixed(2)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(
                    Icons.delete,
                    color: Colors.blueGrey,
                  ),
                  onTap: () {
                    _delete(context, oneFoodList[position]);
                  },
                ),
              ],
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              //TODO navigateToDetail(this.oneFoodList[position], 'Edit OneFood');
            },
          ),
        );
      },
    );
  }

  getFirstLetter(String title) {
    return title.substring(0, 2).toUpperCase();
  }

  void _delete(BuildContext context, OneFood oneFood) async {
    print('dletet');
    print(oneFood);
    int result = await databaseHelper.deleteOneFood(oneFood.time);
    print(result);
    if (result != 0) {
      int len = min(24, oneFood.label.length);
      String name = oneFood.label.substring(0, len - 1);
      if (oneFood.label.length > len) {
        name += '...';
      }
      _showSnackBar(context, '$name Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  // void navigateToDetail(OneFood oneFood, String title) async {
  //   bool result =
  //       await Navigator.push(context, MaterialPageRoute(builder: (context) {
  //     return OneFoodDetail(oneFood, title);
  //   }));

  //   if (result == true) {
  //     updateListView();
  //   }
  // }

  void updateListView() {
    print('update list view');
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<OneFood>> oneFoodListFuture = databaseHelper.getOneFoodList();
      oneFoodListFuture.then((oneFoodList) {
        setState(() {
          this.oneFoodList = oneFoodList;
          this.count = oneFoodList.length;
        });
      });
    });
  }
}
