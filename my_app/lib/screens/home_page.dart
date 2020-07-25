import 'package:flutter/material.dart';
import 'package:my_app/screens/second_page.dart';
import 'package:my_app/database.dart';
import 'package:sqflite/sqflite.dart';

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
        Card(child: getCalories("day")),
        Expanded(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: getOneFoodListView()),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool a = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QrCodeScan()),
          );
          if (a) {
            updateListView();
          }
        },
        tooltip: 'Add new activity',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget getCalories(String time) {
    print('getcalories');
    int timeinterval;
    String message;
    if (time == "day") {
      timeinterval = 86400;
      message = "the last 24 hours";
    } else if (time == "week") {
      timeinterval = 86400 * 7;
      message = "this week";
    } else if (time == "hour") {
      timeinterval = (86400 / 24).round();
      message = "the last hour";
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
    return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 25.0,
          horizontal: 5.0,
        ),
        child: Text(
          totalCalories.toStringAsFixed(2) + " Calories recorded in " + message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
          ),
        ));
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
      String name = oneFood.label.substring(0, 24);
      if (oneFood.label.length > 25) {
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
