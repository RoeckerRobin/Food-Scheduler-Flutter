import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'foodItem.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<FoodItem> foodItems = [];
  final nameController = TextEditingController();
  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void deleteFoodItem(FoodItem foodItem) {
    foodItems.remove(foodItem);
    foodItems.sort((a, b) {
      return a.expiryDate.compareTo(b.expiryDate);
    });
    setState(() {});
  }

  void addFoodItem() {
    foodItems.add(FoodItem(
        name: nameController.text,
        expiryDate: date));
    foodItems.sort((a, b) {
      return a.expiryDate.compareTo(b.expiryDate);
    });
    setState(() {});
  }

  void cleanForm() {
    nameController.text = "";
  }

  Widget _buildPopupDialog(BuildContext context) {
    return AlertDialog(
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    const Text("Add Food"),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Username'),
                      controller: nameController,
                    ),
                    DateTimePicker(
                        type: DateTimePickerType.dateTimeSeparate,
                        dateMask: 'd MMM, yyyy',
                        initialValue: DateTime.now().toString(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        icon: Icon(Icons.event),
                        dateLabelText: 'Date',
                        timeLabelText: "Hour",
                        selectableDayPredicate: (date) {
                          // Disable weekend days to select from the calendar
                          if (date.weekday == 6 || date.weekday == 7) {
                            return false;
                          }

                          return true;
                        },
                        onChanged: (val) => date = DateTime.parse(val)),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () {
                          Navigator.of(context).pop();
                          addFoodItem();
                        },
                        child: const Text("Add"))
                  ],
                ),
              ),
            ),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food Scheduler"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: foodItems.map((foodItem) {
              return Container(
                child: Card(
                  child: ListTile(
                      title: Text(foodItem.name),
                      subtitle: Text("Expiry Date: ${foodItem.expiryDate}"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          cleanForm();
          showDialog(
            context: context,
            builder: (BuildContext context) => _buildPopupDialog(context),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
