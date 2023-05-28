import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sample/polygon_drawer.dart';
import 'package:sample/routes/home/common_list.dart';
import 'package:sample/routes/home/home_grid/home_tile.dart';
import 'package:sample/routes/home/tab_info.dart';
import 'package:sample/routes/home/user_detail/user_detail.dart';
import 'package:sample/routes/home/user_list.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget appBarTitle = Text(
    "ホーム",
    style: TextStyle(
        color: Color.fromRGBO(100, 205, 250, 1.0), fontWeight: FontWeight.bold),
  );
  Icon icon = Icon(Icons.search, color: Colors.blueGrey);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  String text;
  bool isLoading = false;
  bool _isSearching = false;
  var users;
  String input = '';

  final List<TabInfo> _tabs = [
    TabInfo("最近", UserList()),
    TabInfo("おなじシュミ", CommonList()),
  ];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 130) / 2;
    final double itemWidth = size.width / 2;

    return DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            key: _scaffoldKey,
            drawerEdgeDragWidth: 0,
            drawer: PolygonDrawer(),
            appBar: buildAppBar(context),
            body: (_isSearching != true)
                ? TabBarView(children: _tabs.map((tab) => tab.widget).toList())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('user')
                        .orderBy('title')
                        .startAt([input])
                        .endAt([input + '\uf8ff'])
                        .limit(20)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Something went wrong'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return GridView.count(
                        // ignore: deprecated_member_use
                        primary: false,
                        padding: const EdgeInsets.all(5.0),
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        crossAxisCount: 2,
                        childAspectRatio: (itemWidth / itemHeight),
                        // ignore: deprecated_member_use
                        children: snapshot.data.documents
                            .map((DocumentSnapshot document) {
                          String title = document.data()['title'];
                          String imageURL = document.data()['imageURL'];
                          String headerURL = document.data()['headerURL'];
                          String commentText = document.data()['comment'];
                          List hobbylist = document.data()['hobby'];

                          return Hero(
                              tag: 'list' + title,
                              child: GestureDetector(
                                child: HomeTile(
                                    title, imageURL, commentText, hobbylist),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserDetail(
                                          title,
                                          imageURL,
                                          headerURL,
                                          commentText,
                                          hobbylist),
                                      fullscreenDialog: true,
                                    ),
                                  );
                                },
                              ));
                        }).toList(),
                      );
                    },
                  )));
  }

  //バー
  Widget buildAppBar(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: appBarTitle,
        leading: InkWell(
          onTap: () => _scaffoldKey.currentState.openDrawer(),
          child: Icon(
            Icons.menu,
            color: Colors.blueGrey,
          ),
        ),
        bottom: (_isSearching != true)
            ? PreferredSize(
                child: Ink(
                  //color: Color.fromRGBO(37, 183, 192, 0.3),
                  child: TabBar(
                    labelColor: Color.fromRGBO(100, 205, 250, 1.0),
                    labelStyle: TextStyle(
                        //fontFamily: 'Noto_Serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    unselectedLabelColor: Colors.grey,
                    //isScrollable: true,
                    indicatorColor: Color.fromRGBO(100, 205, 250, 1.0),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 3,
                    tabs: _tabs.map((TabInfo tab) {
                      return Tab(
                        text: tab.label,
                      );
                    }).toList(),
                  ),
                ),
                preferredSize: Size.fromHeight(50.0),
              )
            : PreferredSize(
                child: Container(),
                preferredSize: Size.fromHeight(0.0),
              ),
        actions: <Widget>[
          IconButton(
            icon: icon,
            onPressed: () {
              setState(() {
                if (this.icon.icon == Icons.search) {
                  this.icon = Icon(
                    Icons.close,
                    color: Colors.blueGrey,
                  );
                  _isSearching = true;
                  this.appBarTitle = TextField(
                      enabled: true,
                      autofocus: true,
                      controller: _controller,
                      style: TextStyle(
                        color: Colors.blueGrey,
                      ),
                      decoration: InputDecoration(
                          prefixIcon:
                              Icon(Icons.search, color: Colors.blueGrey),
                          hintText: "すべてのユーザーを検索",
                          hintStyle: TextStyle(color: Colors.blueGrey)),
                      onChanged: (text) {
                        setState(() {
                          input = text;
                          _isSearching = true;
                        });
                      });
                } else {
                  setState(() {
                    this.icon = Icon(
                      Icons.search,
                      color: Colors.blueGrey,
                    );
                    this.appBarTitle = Text(
                      "ホーム",
                      style: TextStyle(
                          color: Color.fromRGBO(100, 205, 250, 1.0),
                          fontWeight: FontWeight.bold),
                    );
                    _controller.clear();
                    _isSearching = false;
                  });
                }
              });
            },
          ),
        ]);
  }
}
