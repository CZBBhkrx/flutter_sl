import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../provide/child_category.dart';
import '../config/service_url.dart';
import '../service/service_method.dart';
import 'dart:convert';
import '../model/category.dart';
import 'package:provide/provide.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({Key key}) : super(key: key);

  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('商品类别'),
        backgroundColor: Colors.pink,
      ),
      body: Row(
        children: <Widget>[
          LeftCategoryNav(),
          Column(
            children: <Widget>[RightCategoryNav()],
          )
        ],
      ),
    );
  }
}

//左侧菜单栏
class LeftCategoryNav extends StatefulWidget {
  LeftCategoryNav({Key key}) : super(key: key);

  _LeftCategoryNavState createState() => _LeftCategoryNavState();
}

//左侧菜单控件区
class _LeftCategoryNavState extends State<LeftCategoryNav> {
  List list = [];
  @override
  void initState() {
    _getCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(180),
      decoration: BoxDecoration(
          border: Border(right: BorderSide(width: 1, color: Colors.black12))),
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _leftInkWell(index);
        },
      ),
    );
  }

//获取左侧菜单数据
  void _getCategory() async {
    await request(GET_CATEGORY).then((val) {
      var data = json.decode(val.toString());
      print(data);
      CategoryModel category = CategoryModel.fromJson(data);
      setState(() {
        list = category.data;
      });
    });
  }

//左侧菜单的子控件
  Widget _leftInkWell(int index) {
    return InkWell(
      onTap: () {
        var childList = list[index].bxMallSubDto;
        Provide.value<ChildCategory>(context).getChildCategory(childList);
      },
      child: Container(
        height: ScreenUtil().setHeight(80),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border:
                Border(bottom: BorderSide(width: 1, color: Colors.black12))),
        child: Text(
          list[index].mallCategoryName,
          style: TextStyle(fontSize: ScreenUtil().setSp(26)),
        ),
      ),
    );
  }
}

//右侧顶部导航菜单
class RightCategoryNav extends StatefulWidget {
  RightCategoryNav({Key key}) : super(key: key);

  _RightCategoryNavState createState() => _RightCategoryNavState();
}

class _RightCategoryNavState extends State<RightCategoryNav> {
  List<BxMallSubDto> list = [];
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Provide<ChildCategory>(
        builder: (context, child, childCategory) {
          return Container(
            height: ScreenUtil().setHeight(80),
            width: ScreenUtil().setWidth(560),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(width: 1, color: Colors.black12))),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: childCategory.childCategoryList.length,
              itemBuilder: (context, index) {
                return _rightInkWell(childCategory.childCategoryList[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

Widget _rightInkWell(BxMallSubDto item) {
  return InkWell(
    onTap: () {},
    child: Container(
      padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
      child: Text(
        item.mallSubName,
        style: TextStyle(fontSize: ScreenUtil().setSp(26)),
      ),
    ),
  );
}
