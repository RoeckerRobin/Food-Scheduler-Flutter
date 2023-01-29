import 'package:hive/hive.dart';

part 'foodItem.g.dart';

@HiveType(typeId: 0)
class FoodItem extends HiveObject{
  @HiveField(0)
  String name;
  @HiveField(1)
  DateTime expiryDate;
  FoodItem({required this.name, required this.expiryDate});
}