import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_shop/config/service_url.dart';
import '../service/service_method.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  int page = 1;
  List<Map> hotGoodsList = [];
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getHotGoods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('百姓生活+')),
      body: FutureBuilder(
        future: request(HOMEPAGE_CONTENT, formData: null),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print('返回的数据------->$snapshot');
            var data = json.decode(snapshot.data.toString());
            List<Map> swiperDataList = (data['data']['slides'] as List).cast();
            List<Map> navigatorList = (data['data']['category'] as List).cast();
            String adPicture =
                data['data']['advertesPicture']['PICTURE_ADDRESS'];
            String leaderImage = data['data']['shopInfo']['leaderImage'];
            String leaderPhone = data['data']['shopInfo']['leaderPhone'];
            List<Map> recommandList =
                (data['data']['recommend'] as List).cast();

            String floor1Title = data['data']['floor1Pic']['PICTURE_ADDRESS'];
            String floor2Title = data['data']['floor2Pic']['PICTURE_ADDRESS'];
            String floor3Title = data['data']['floor3Pic']['PICTURE_ADDRESS'];

            List<Map> floor1 = (data['data']['floor1'] as List).cast();
            List<Map> floor2 = (data['data']['floor2'] as List).cast();
            List<Map> floor3 = (data['data']['floor3'] as List).cast();
            return EasyRefresh(
              refreshFooter: ClassicsFooter(
                key: _footerKey,
                bgColor: Colors.white,
                textColor: Colors.pink,
                moreInfoColor: Colors.pink,
                showMore: true,
                noMoreText: '没有更多数据了',
                moreInfo: '加载中',
                loadReadyText: '上拉加载',
              ),
              child: ListView(
                children: <Widget>[
                  SwiperDiy(swiperDataList: swiperDataList),
                  TopNavigator(
                    navigatorList: navigatorList,
                  ),
                  AdBanner(
                    adPicture: adPicture,
                  ),
                  LeaderPhpne(
                      leaderImage: leaderImage, leaderPhone: leaderPhone),
                  Recommend(
                    recommendList: recommandList,
                  ),
                  FloorTitle(picture_adress: floor1Title),
                  FloorContent(
                    floorGoodsList: floor1,
                  ),
                  FloorTitle(
                    picture_adress: floor2Title,
                  ),
                  FloorContent(
                    floorGoodsList: floor2,
                  ),
                  FloorTitle(
                    picture_adress: floor3Title,
                  ),
                  FloorContent(
                    floorGoodsList: floor3,
                  ),
                  _hotGoods()
                ],
              ),
              loadMore: () {
                _getHotGoods();
              },
            );
          } else {
            return Center(
                child:
                    Text('加载中....')); //, fontSize: ScreenUtil().setSp(28,false)
          }
        },
      ),
    );
  }

//获取数据以及翻页时获取数据
  void _getHotGoods() async {
    var formData = {'page': page};
    await request(HOMEPAGE_BELOW_CONTENT, formData: formData).then((val) {
      var data = json.decode(val.toString());
      List<Map> newGoods = (data['data'] as List).cast();
      setState(() {
        //翻页时数据的处理
        hotGoodsList.addAll(newGoods);
        page++;
      });
    });
  }

  Widget hotTitle = Container(
    margin: EdgeInsets.only(top: 10),
    alignment: Alignment.center,
    padding: EdgeInsets.all(5),
    color: Colors.transparent,
    child: Text("火爆专区"),
  );

//流式布局
  Widget _wrapList() {
    if (hotGoodsList.length != 0) {
      List<Widget> listWidget = hotGoodsList.map((val) {
        return InkWell(
          onTap: null,
          child: Container(
            width: ScreenUtil().setWidth(370),
            color: Colors.white,
            padding: EdgeInsets.only(bottom: 3),
            child: Column(
              children: <Widget>[
                Image.network(val['image'], width: ScreenUtil().setWidth(350)),
                Text(val['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.pink, fontSize: ScreenUtil().setSp(26))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('￥${val['mallPrice']}'),
                    Text(
                      '￥${val['price']}',
                      style: TextStyle(
                          color: Colors.black26,
                          decoration: TextDecoration.lineThrough),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }).toList();

      return Wrap(
        spacing: 2,
        children: listWidget,
      );
    } else {
      return Text('');
    }
  }

  Widget _hotGoods() {
    return Container(
      child: Column(
        children: <Widget>[hotTitle, _wrapList()],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

//首页轮播组件
class SwiperDiy extends StatelessWidget {
  final List swiperDataList;

  //官方推荐的构造函数书写
  const SwiperDiy({Key key, this.swiperDataList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(333),
      width: ScreenUtil().setWidth(750),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Image.network("${swiperDataList[index]['image']}",
              fit: BoxFit.fill);
        },
        itemCount: swiperDataList.length,
        pagination: SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}

// GridView 类别导航制作
class TopNavigator extends StatelessWidget {
  final List navigatorList;
  TopNavigator({Key key, this.navigatorList}) : super(key: key);

//自定义的自条目的样式
  Widget _gridViewItemUI(BuildContext context, item) {
    return InkWell(
      onTap: () {
        print('点击了导航');
      },
      child: Column(
        children: <Widget>[
          Image.network(item['image'], width: ScreenUtil().setWidth(95)),
          Text(item['mallCategoryName'])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (this.navigatorList.length > 10) {
      this.navigatorList.removeRange(10, this.navigatorList.length);
    }
    return Container(
      height: ScreenUtil().setHeight(320),
      padding: EdgeInsets.all(3.0),
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        padding: EdgeInsets.all(5.0),
        children: navigatorList.map((item) {
          return _gridViewItemUI(context, item);
        }).toList(),
      ),
    );
  }
}

//广告区域
class AdBanner extends StatelessWidget {
  final String adPicture;
  const AdBanner({Key key, this.adPicture}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(adPicture),
    );
  }
}

//拨打店长电话
class LeaderPhpne extends StatelessWidget {
  final String leaderPhone; //店��电话
  final String leaderImage; //店长图片
  const LeaderPhpne({Key key, this.leaderImage, this.leaderPhone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: _launcherURL,
        child: Image.network(leaderImage),
      ),
    );
  }

  void _launcherURL() async {
    String url = "tel:" + leaderPhone;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'url���能进行访问';
    }
  }
}

//推荐模块
class Recommend extends StatelessWidget {
  final List recommendList;
  const Recommend({Key key, this.recommendList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(460),
      margin: EdgeInsets.only(top: 10),
      child: Column(
        children: <Widget>[_titleWidget(), _recommandList()],
      ),
    );
  }

//标题���法
  Widget _titleWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(10, 2, 0, 5),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(width: 1, color: Colors.black12))),
      child: Text('商品推荐', style: TextStyle(color: Colors.pink)),
    );
  }

//商品单独项方法
  Widget _item(index) {
    return InkWell(
      onTap: () {},
      child: Container(
        height: ScreenUtil().setHeight(400),
        width: ScreenUtil().setWidth(250),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(width: 1, color: Colors.black12))),
        child: Column(children: <Widget>[
          Image.network(recommendList[index]['image']),
          Text('￥${recommendList[index]['mallPrice']}'),
          Text('￥${recommendList[index]['mallPrice']}',
              style: TextStyle(
                  decoration: TextDecoration.lineThrough, color: Colors.grey))
        ]),
      ),
    );
  }

  //���向列表widget
  Widget _recommandList() {
    return Container(
      height: ScreenUtil().setHeight(400),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendList.length,
        itemBuilder: (context, index) {
          return _item(index);
        },
      ),
    );
  }
}

// 楼层的title
class FloorTitle extends StatelessWidget {
  final String picture_adress;
  const FloorTitle({Key key, this.picture_adress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Image.network(this.picture_adress),
    );
  }
}

// 楼层商品
class FloorContent extends StatelessWidget {
  final List floorGoodsList;
  const FloorContent({Key key, this.floorGoodsList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[_firstRow(), _otherGoods()],
      ),
    );
  }

//其��商品的楼层
  Widget _otherGoods() {
    return Row(
      children: <Widget>[
        _goodsItem(floorGoodsList[3]),
        _goodsItem(floorGoodsList[4])
      ],
    );
  }

  Widget _firstRow() {
    return Row(
      children: <Widget>[
        _goodsItem(floorGoodsList[0]),
        Column(
          children: <Widget>[
            _goodsItem(floorGoodsList[1]),
            _goodsItem(floorGoodsList[2])
          ],
        )
      ],
    );
  }

//单个图片
  Widget _goodsItem(Map goods) {
    return Container(
      height: ScreenUtil().setHeight(220),
      child: InkWell(
        onTap: () {
          print('点击了楼层商品');
        },
        child: Image.network(goods['image']),
      ),
    );
  }
}
