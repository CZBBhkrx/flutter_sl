import 'package:flutter/material.dart';
import 'package:flutter_shop/model/category.dart';
import 'package:provide/provide.dart';

class ChildCategory with ChangeNotifier {
  List<BxMallSubDto> childCategoryList = [];
  getChildCategory(List list) {
    childCategoryList = list;
    notifyListeners();
  }
}
