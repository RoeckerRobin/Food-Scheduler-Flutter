import 'dart:io';
import 'package:hive/hive.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'foodItem.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory directory = await pathProvider.getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(FoodItemAdapter());
  await Hive.openBox('foodItem_box');
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.green,
      primarySwatch: Colors.green,
    ),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<FoodItem> foodItems = [];
  final nameController = TextEditingController();
  final numberOfObjectsGeneratedPerSecondController = TextEditingController();
  final numberOfSecondsController = TextEditingController();
  DateTime date = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final DateFormat formatter = DateFormat('yyyy-MM-dd   hh:mm');
  bool disableCancelButton = false;

  @override
  void initState() {
    super.initState();
    getFoodItems();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void getFoodItems() async {
    var foodItemBox = await Hive.openBox('foodItem_box');
    for (var foodItem in foodItemBox.values.first) {
      foodItems
          .add(FoodItem(name: foodItem.name, expiryDate: foodItem.expiryDate));
      foodItems.sort((a, b) {
        return a.expiryDate.compareTo(b.expiryDate);
      });
    }
    setState(() {});
  }

  void deleteFoodItem(FoodItem foodItem) async {
    foodItems.remove(foodItem);
    foodItems.sort((a, b) {
      return a.expiryDate.compareTo(b.expiryDate);
    });
    setState(() {});
    var foodItembox = await Hive.openBox('foodItem_box');
    await foodItembox.clear();
    foodItembox.add(foodItems);
  }

  addFoodItem() async {
    Navigator.of(context).pop();
    foodItems.add(FoodItem(name: nameController.text, expiryDate: date));
    foodItems.sort((a, b) {
      return a.expiryDate.compareTo(b.expiryDate);
    });
    setState(() {});
    var foodItembox = await Hive.openBox('foodItem_box');
    await foodItembox.clear();
    foodItembox.add(foodItems);
  }

  void cleanAddForm() {
    nameController.text = "";
  }

  void cleanTestForm() {
    numberOfSecondsController.text = "";
    numberOfObjectsGeneratedPerSecondController.text = "";
  }

  void testFlutter() async {
    disableCancelButton = true;
    List testList = [];
    for (var i = 0; i < int.parse(numberOfSecondsController.text); i++) {
      for (var j = 0;
          j < int.parse(numberOfObjectsGeneratedPerSecondController.text);
          j++) {
        testList.add(Object());
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    Navigator.pop(context, 'Stop');
    disableCancelButton = false;
  }

  Widget _buildAddPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Food"),
      content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                style: const TextStyle(color: Colors.green),
                decoration: const InputDecoration(labelText: 'Username'),
                controller: nameController,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.contains(RegExp((r'[0-9]')))) {
                    return "Please enter a valid food name";
                  }
                  return null;
                },
              ),
              DateTimePicker(
                  cursorColor: Colors.green,
                  type: DateTimePickerType.dateTimeSeparate,
                  dateMask: 'd MMM, yyyy',
                  initialValue: DateTime.now().toString(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  icon: const Icon(Icons.event),
                  dateLabelText: 'Date',
                  timeLabelText: "Hour",
                  onChanged: (val) => date = DateTime.parse(val)),
            ],
          )),
      actions: <Widget>[
        TextButton(
          style: const ButtonStyle(
            foregroundColor: MaterialStatePropertyAll(Colors.red),
          ),
          onPressed: () => {Navigator.pop(context, 'Stop')},
          child: const Text('Cancel'),
        ),
        TextButton(
          style: const ButtonStyle(
            foregroundColor: MaterialStatePropertyAll(Colors.green),
          ),
          onPressed: () => {
            if (_formKey.currentState!.validate()) {addFoodItem()}
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildTestPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Test Flutter"),
      content: Form(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'Number of objects generated per seconds'),
            controller: numberOfObjectsGeneratedPerSecondController,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Number of seconds'),
            controller: numberOfSecondsController,
          ),
        ],
      )),
      actions: <Widget>[
        TextButton(
          onPressed: () => {
            if (!disableCancelButton) {Navigator.pop(context, 'Stop')}
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => {
            if (!disableCancelButton) {testFlutter()}
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Food Scheduler"),
          backgroundColor: Colors.green,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: foodItems.map((foodItem) {
                return Container(
                  child: Card(
                    child: ListTile(
                        title: Text(foodItem.name),
                        subtitle: Text(
                            "Expiry Date: ${formatter.format(foodItem.expiryDate.toLocal())}"),
                        trailing: IconButton(
                          color: Colors.red,
                          icon: const Icon(
                            Icons.delete,
                          ),
                          onPressed: () {
                            deleteFoodItem(foodItem);
                          },
                        )),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: const IconThemeData(size: 22),
          backgroundColor: Colors.green,
          visible: true,
          curve: Curves.bounceIn,
          children: [
            SpeedDialChild(
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              backgroundColor: Colors.green,
              onTap: () {
                cleanAddForm();
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildAddPopupDialog(context),
                );
              },
            ),
            SpeedDialChild(
              child: const Icon(
                Icons.handyman,
                color: Colors.white,
              ),
              backgroundColor: Colors.green,
              onTap: () {
                cleanTestForm();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) =>
                      _buildTestPopupDialog(context),
                );
              },
            )
          ],
        ));
  }
}
