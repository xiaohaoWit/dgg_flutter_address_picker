import 'package:dgg_flutter_address_picker/theme.dart';
import 'package:flutter/material.dart';
import 'package:dgg_flutter_address_picker/utils/screen.dart';
import 'package:dgg_flutter_address_picker/pcData.dart';
import 'dart:async';

class DggPicker {
  static Future<Null> openPicker({
    @required BuildContext context,
    List startPickerData,
    PickerTheme pickerTheme:PickerTheme.Default,
    // 暗黑模式
    bool isDark=false,
    // 默认传入的初始数据
    bool requestFlag = true,
    // 是网络请求下级数据的picker，还是使用的本地多元数组数据
    String pickerTitle = "请选择",
    // picker的原始数据
    int series,
    // 级数,使用本地数据必填
    String startCode = "",
    // 网络请求初始code，不传默认为空字符串
    Function pickerCallback,
    // 获取值后回调
    Function networkCallback
  }){
    assert(context!=null);
    assert(requestFlag!=null);
    assert(pickerTitle!=null);
    assert(series!=null);
    if(series>3||series<1){
        print("级数不能大于3,且不能小于1");
        return null;
    }
    switch(requestFlag){
      case false:
        List local=PickerData.getData();
        List pickerData=[];
        pickerData=getLocalData(local);
        List swiperArr=[];
        if(startPickerData!=null&&startPickerData.length!=0){
          swiperArr=handlelocalData(series,startPickerData,pickerData);
        }else{
          swiperArr.add(pickerData);
        }
        show(
          context,
          isDark,
          startPickerData,
          pickerTitle,
          requestFlag,
          swiperArr,
          series,
          pickerTheme,
          pickerCallback,
          networkCallback
        );
        break;
      case true:
        // 如果是网络请求数据的话
        if(networkCallback!=null){
          if(startPickerData!=null&&startPickerData.length!=0){
            // 请求网络数据后打开picker
            handleNetworkData(startCode,series,startPickerData,networkCallback).then((swiperArr){
              show(
                context,
                isDark,
                startPickerData,
                pickerTitle,
                requestFlag,
                swiperArr,
                series,
                pickerTheme,
                pickerCallback,
                networkCallback
              );
            });
          }else{
            getFutureData(startCode,networkCallback).then((provinceArr){
              List swiperArr=[];
              swiperArr.add(provinceArr);
              show(
                context,
                isDark,
                startPickerData,
                pickerTitle,
                requestFlag,
                swiperArr,
                series,
                pickerTheme,
                pickerCallback,
                networkCallback
              );
            });
          }
        }else{
          print("网络请求数据，需要配置回调方法——networkCallback");
        }
        break;
      default:
        print("请传入正确的requestFlag值");
    }
  }
}
// 处理本地数据
getLocalData(List local){
  List handleData = [];
  local.forEach((a){
    LocalData provinceItem=LocalData.fromJson(a);
    provinceItem.checkFlag=false;
    List cityArr=[];
    provinceItem.children.forEach((b){
      LocalData cityItem=LocalData.fromJson(b);
      cityItem.checkFlag=false;
      cityArr.add(cityItem);
      List areaArr=[];
      cityItem.children.forEach((c){
        LocalData areaItem=LocalData.fromJson(c);
        areaItem.checkFlag=false;
        areaArr.add(areaItem);
      });
      cityItem.children=areaArr;
    });
    provinceItem.children=cityArr;
    handleData.add(provinceItem);
  });
  return handleData;
}
// 弹起picker
Future show(
    BuildContext context,
    bool isDark,
    List startPickerData,
    String pickerTitle,
    bool requestFlag,
    List pickerData,
    int series,
    PickerTheme pickerTheme,
    Function pickerCallback,
    Function networkCallback
  ){
  return showModalBottomSheet(
    context:context,
    builder:(BuildContext context){
      return Stack(
        children: <Widget>[
          Container(
            height: 30.0,
            width: double.infinity,
            color: isDark ? Color.fromRGBO(15, 15, 15, 1) : Colors.black54,
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Color.fromRGBO(45, 45, 46, 1) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              )
            ),
          ),
          PickerContent(
            sheetContext: context,
            isDark:isDark,
            startPickerData:startPickerData,
            pickerTitle: pickerTitle,
            requestFlag: requestFlag,
            pickerData: pickerData,
            series: series,
            pickerTheme:pickerTheme,
            pickerCallback:pickerCallback,
            networkCallback:networkCallback
          )
        ],
      );
    }
  );
}
// 使用本地数据，如果有默认数据则需要先装填分级数据
handlelocalData(
  int series,
  List startPickerData,
  List pickerData
){
  List swiperArr=[];
  int seriesIndex=series;
  for(int a=0;a<pickerData.length;a++){
    if(pickerData[a].name==startPickerData[0]){
      // 将默认的省级数据选中
      pickerData[a].checkFlag=true;
      // 装入省级数据
      swiperArr.add(pickerData);
      seriesIndex--;
      // 判断是否符合级数
      if(swiperArr.length>=series){
        return swiperArr;
      }
      if(seriesIndex==0||startPickerData.length<2){
        swiperArr.add(pickerData[a].children);
        return swiperArr;
      }
      for(int b=0;b<pickerData[a].children.length;b++){
        if(pickerData[a].children[b].name==startPickerData[1]){
          // 将默认的市级数据选中
          pickerData[a].children[b].checkFlag=true;
          // 装入市级数据
          swiperArr.add(pickerData[a].children);
          seriesIndex--;
          // 判断是否符合级数
          if(swiperArr.length>=series){
            return swiperArr;
          }
          if(seriesIndex==0||startPickerData.length<3){
            swiperArr.add(pickerData[a].children[b].children);
            return swiperArr;
          }
          for(int c=0;c<pickerData[a].children[b].children.length;c++){
            if(pickerData[a].children[b].children[c].name==startPickerData[2]){
              // 将默认的区级数据选中
              pickerData[a].children[b].children[c].checkFlag=true;
              // 装入区级数据
              swiperArr.add(pickerData[a].children[b].children);
              return swiperArr;
            }
          }
        }
      }
    }
  }
}
// 如果有默认值则需要初始异步请求网路数据.
Future handleNetworkData(
  String startCode,
  int series,
  List startPickerData,
  Function networkCallback
){
  Completer completer = new Completer();
  int seriesIndex=series;
  List swiperArr=[];
  List provinceArr=[];
  List cityArr=[];
  List areaArr=[];
  getFutureData(startCode,networkCallback).then((classA){
    String codeAStorage="";
    if(classA.length!=0){
      classA.forEach((a){
        a.checkFlag=false;
        try{
          if(a.name == startPickerData[0]){
            a.checkFlag=true;
            codeAStorage=a.code;
          }
        }catch(e){}
        provinceArr.add(a);
      });
      swiperArr.add(provinceArr);
      seriesIndex--;
      if(seriesIndex==0){
        completer.complete(swiperArr);
        return;
      }
      if(codeAStorage!=""){
        getFutureData(codeAStorage,networkCallback).then((classB){
          String codeBStorage="";
          if(classB.length!=0){
            classB.forEach((b){
              b.checkFlag=false;
              try{
                if(b.name == startPickerData[1]){
                  b.checkFlag=true;
                  codeBStorage=b.code;
                }
              }catch(e){}
              cityArr.add(b);
            });
            swiperArr.add(cityArr);
            seriesIndex--;
            if(seriesIndex==0){
              completer.complete(swiperArr);
              return;
            }
            if(codeBStorage!=""){
              getFutureData(codeBStorage,networkCallback).then((classC){
                if(classC.length!=0){
                  classC.forEach((c){
                    c.checkFlag=false;
                    try{
                      if(c.name == startPickerData[2]){
                        c.checkFlag=true;
                      }
                    }catch(e){}
                    areaArr.add(c);
                  });
                  swiperArr.add(areaArr);
                  completer.complete(swiperArr);
                }else{
                  completer.complete(swiperArr);
                  print("第三组数据为空");
                }
              });
            }else{
              completer.complete(swiperArr);
            }
          }else{
            completer.complete(swiperArr);
            print("第二组数据为空");
          }
        });
      }else{
        completer.complete(swiperArr);
      }
    }else{
      print("首次获取数据为空");
    }
  });
  return completer.future;
}
// 简单请求回调函数
Future getFutureData(String code,Function networkCallback){
  Completer completerNet = new Completer();
  networkCallback(code,(List dataList){
    completerNet.complete(dataList);
  });
  return  completerNet.future;
}
class PickerContent extends StatefulWidget {
  final BuildContext sheetContext;
  final bool isDark;
  final List startPickerData;
  final String pickerTitle;
  final bool requestFlag;
  final List pickerData;
  final int series;
  final PickerTheme pickerTheme;
  final Function pickerCallback;
  final Function networkCallback;
  PickerContent({
    Key key,
    @required this.sheetContext,
    @required this.isDark,
    this.startPickerData,
    @required this.pickerTitle,
    @required this.requestFlag,
    this.pickerData,
    this.series,
    this.pickerTheme,
    this.pickerCallback,
    this.networkCallback
  }) : super(key: key);
  @override
  _PickerContent createState() => _PickerContent();
}
class _PickerContent  extends State<PickerContent> with TickerProviderStateMixin, WidgetsBindingObserver {
  // picker原始数据
  List pickerData = [];

  // picker级数series
  int series = 0;

  // 已选中的数据
  List startPickerData = [];

  // 是否是第一次打开picker
  bool isFirstOpen=true;

  // picker的title名字
  String pickerTitle = "";

  // 回传数据集合
  List callbackData=[];

  // 是否是网络请求
  bool requestFlag = true;

  // 上一级的上下文
  BuildContext sheetContext;

  // view集合
  List swiperArr = [];

  // 是否需要触犯滚动
  bool nextSwiper=false;

  // 将要滚动到的view
  int nextSwiperindex=0;

  // 创建控制器
  TabController _tabController;
  double controllerOneIndex;
  double controllerTwoIndex;
  double controllerThreeIndex;
  ScrollController controllerOne = ScrollController();
  ScrollController controllerTwo = ScrollController();
  ScrollController controllerThree = ScrollController();

  // tab内容顶部
  List<Widget> tabBarList=<Tab>[
    Tab(
      text: "请选择"
    )
  ];

  @protected
  // bool get wantKeepAlive=>true;
  @override
  void initState() {
    super.initState();
    swiperArr=widget.pickerData;
    try{
      if(widget.startPickerData.length!=0){
        tabBarList=[];
        for(int i=0;i<widget.startPickerData.length;i++){
          if(i<widget.series){
            tabBarList.add(Tab(text: widget.startPickerData[i]));
          }
        }
        if(tabBarList.length<widget.series){
          tabBarList.add(Tab(text: "请选择"));
        }
      } 
    }catch(e){}
    if(swiperArr.length!=0){
      for(int j=0;j<swiperArr.length;j++){
        List a=swiperArr[j];
        for(int i=0;i<a.length;i++){
          if(a[i].checkFlag){
            callbackData.add(a[i]);
            switch (j) {
              case 0:
                controllerOneIndex=double.parse(i.toString());
                break;
              case 1:
                controllerTwoIndex=double.parse(i.toString());
                break;
              case 2:
                controllerThreeIndex=double.parse(i.toString());
                break;
              default:
            }
          }
        }
        
      }
    }
    _tabController=new TabController(
      vsync: this,
      length: swiperArr.length
    );
    _tabController.addListener((){
      if(_tabController.indexIsChanging){}
    });
  }
  @override
  void dispose() {
    print("已注销");
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    setScreenSize(context);
    WidgetsBinding.instance.addPostFrameCallback((callback){
      if(isFirstOpen){
        isFirstOpen=false;
        if(controllerOneIndex!=null){
          controllerOne.jumpTo(controllerOneIndex*setHeight(90.0));
        }
        if(controllerTwoIndex!=null){
          _tabController.animateTo(1,duration: Duration(milliseconds: 10));
          Future.delayed(Duration(milliseconds: 200),(){
            controllerTwo.jumpTo(controllerTwoIndex*setHeight(90.0));
          });
        }
        if(controllerThreeIndex!=null){
          _tabController.animateTo(2,duration: Duration(milliseconds: 10));
          Future.delayed(Duration(milliseconds: 200),(){
            controllerThree.jumpTo(controllerThreeIndex*setHeight(90.0));
          });
        }
      }
      if(nextSwiper){
        nextSwiper=false;
        _tabController.animateTo(nextSwiperindex);
      }else{
        return null;
      }
    });
    pickerTitle = widget.pickerTitle;
    requestFlag = widget.requestFlag;
    sheetContext = widget.sheetContext;
    pickerData = widget.pickerData;
    series=widget.series;
    startPickerData = widget.startPickerData??[];
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? Color.fromRGBO(45, 45, 46, 1) : Colors.white, 
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0)
        )
      ),
      child: Column(
        children: <Widget>[
          pickerTop(context,pickerTitle),
          pickerTopTitle(context),
          Expanded(
            child:tabBarView(context),
          )
        ],
      ),
    );
  }
  // 刷新控制器
  refreshController(){
    _tabController.dispose();
    _tabController=new TabController(
      vsync: this,
      length: swiperArr.length
    );
    _tabController.addListener((){if(_tabController.indexIsChanging){}});
  }

  // picker头部操作区域
  Widget pickerTop(BuildContext context,String pickerTitle){
    return Container(
      height: 50.0,
      child: Stack(
        children: <Widget>[
          Container(
            child: Center(
              child: Text(
                pickerTitle,
                style: TextStyle(color:widget.isDark ? Color.fromRGBO(224, 224, 224, 1) : Color.fromRGBO(51,51,51, 1))
                // widget.pickerTheme.titleStyle
              ),
            ),
          ),
          Positioned(
            top: 15.0,
            right: 10.0,
            child: InkWell(
              onTap: (){
                  Navigator.of(sheetContext).maybePop();
              },
              child: Container(
                width: 20.0,
                height: 20.0,
                child: Icon(
                  Icons.close,
                  color: widget.isDark ? Color.fromRGBO(224, 224, 224, 1) : Color(0xFF666666),
                  size: 20.0,
                )
              ),
            ),
          )
        ],
      )
    );
  }
  Widget pickerTopTitle(BuildContext context){
    return Container(
      height: setHeight(80.0),
      width: setWidth(750.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child:Container(
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                controller: _tabController,
                indicatorColor:Colors.transparent,
                labelColor:widget.pickerTheme.tabbarColor,
                unselectedLabelColor:widget.isDark ? Color.fromRGBO(134, 134, 134, 1) : Color.fromRGBO(0, 0, 0, 0.65),
                indicatorSize: TabBarIndicatorSize.label,
                tabs:tabBarList.map((f){
                  return f;
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget tabBarView(BuildContext context){
    return TabBarView(
      controller: _tabController,
      children: 
      swiperArr.asMap().keys.map((i){
        return pickerList(context,i);
      }).toList(),
    );
  }
  Widget pickerList(BuildContext context,int swiperIndex){
    int listLength=swiperArr[swiperIndex].length;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: double.infinity,
      child: ListView.builder(
        itemCount: listLength,
        itemExtent: setHeight(90.0),
        controller: swiperIndex==0?controllerOne:swiperIndex==1?controllerTwo:controllerThree,
        itemBuilder: (BuildContext context, int index){
          return GestureDetector(
            onTap: (){
              clickItem(swiperIndex,index);
            },
            child: Container(
              color: widget.isDark ? Color.fromRGBO(45, 45, 46, 1) : Colors.white,
              height: setHeight(90.0),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20.0),
              child: swiperArr[swiperIndex][index].checkFlag?
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(swiperArr[swiperIndex][index].name,style: TextStyle(color: widget.pickerTheme.itemStyle,fontSize: 14.0),),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20.0),
                    child: Icon(Icons.check,size: 20.0,color: widget.pickerTheme.itemStyle),
                  )
                ],
              ):Text(swiperArr[swiperIndex][index].name,style: TextStyle(color:widget.isDark ? Color.fromRGBO(224, 224, 224, 1) : Color.fromRGBO(51,51,51, 1)),)
            ),
          );
        },
      ),
    );
  }
  // 点击处理事件
  clickItem(int swiperIndex, int index){
    if(swiperArr[swiperIndex][index].checkFlag == false){
      for(var i=0;i<swiperArr[swiperIndex].length;i++){
        swiperArr[swiperIndex][i].checkFlag=false;
      }
      switch (swiperIndex) {
        case 0:
          controllerOneIndex=double.parse(index.toString());
          break;
        case 1:
          controllerTwoIndex=double.parse(index.toString());
          break;
        case 2:
          controllerThreeIndex=double.parse(index.toString());
          break;
        default:
          print("没了");
      }
      swiperArr[swiperIndex][index].checkFlag=true;
      bool continueFlag=getItem(swiperIndex,swiperArr[swiperIndex][index]);
      String tabName=swiperArr[swiperIndex][index].name;
      tabBarList.fillRange(swiperIndex, swiperIndex+1,Tab(text:tabName));
      if(!continueFlag){
        setState(() {});
        return null;
      }
      if(requestFlag==true){
        widget.networkCallback(swiperArr[swiperIndex][index].code,(getdata){
          if(getdata.length!=0){
            if(swiperIndex==swiperArr.length-1){
              swiperArr.add(getdata);
              tabBarList.add(Tab(text:"请选择"));
            }else{
              swiperArr.fillRange(swiperIndex+1, swiperIndex+2,getdata);
              tabBarList.fillRange(swiperIndex+1, swiperIndex+2,Tab(text:"请选择"));
              tabBarList.removeRange(swiperIndex+2,swiperArr.length);
              swiperArr.removeRange(swiperIndex+2, swiperArr.length);
            }
            nextSwiper=true;
            nextSwiperindex=swiperIndex+1;
            refreshController();
            _tabController.index=swiperIndex;
            setState(() {});
          }else{
            widget.pickerCallback(callbackData);
            Navigator.of(sheetContext).maybePop();
          }
        });
      }else{
        if(swiperArr[swiperIndex][index].children!=null&&swiperArr[swiperIndex][index].children.length!=0){
          if(swiperIndex==swiperArr.length-1){
            swiperArr.add(swiperArr[swiperIndex][index].children);
            tabBarList.add(Tab(text:"请选择"));
          }else{
            swiperArr.fillRange(swiperIndex+1, swiperIndex+2,swiperArr[swiperIndex][index].children);
            tabBarList.fillRange(swiperIndex+1, swiperIndex+2,Tab(text:"请选择"));
            tabBarList.removeRange(swiperIndex+2,swiperArr.length);
            swiperArr.removeRange(swiperIndex+2, swiperArr.length);
          }
          nextSwiper=true;
          nextSwiperindex=swiperIndex+1;
          refreshController();
          _tabController.index=swiperIndex;
        }
      }
      setState(() {});
    }
  }
  // 获取选择的条目信息
  getItem(int index,data){
    if(callbackData.length==index){
      callbackData.add(data);
    }else if(callbackData.length>index){
      callbackData.fillRange(index,index+1,data);
      try{
        callbackData.removeRange(index+2, callbackData.length);
      }catch(e){}
    }
    if(index==widget.series-1){
       widget.pickerCallback(callbackData);
       Navigator.of(sheetContext).maybePop();
       return false;
    }
    return true;
  }
}

class LocalData {
  String code;
  String name;
  bool checkFlag;
  List children;

  LocalData({this.code, this.name, this.checkFlag, this.children});

  LocalData.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    checkFlag = json['checkFlag'];
    children = json['children'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    data['checkFlag'] = this.checkFlag;
    data['children'] = this.children;
    return data;
  }
}