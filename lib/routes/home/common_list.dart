import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sample/routes/home/home_grid/home_tile.dart';
import 'package:sample/routes/home/user_detail/user_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonListPage(),
    );
  }
}

class CommonListPage extends StatefulWidget {
  @override
  _CommonListPageState createState() => _CommonListPageState();
}

class _CommonListPageState extends State<CommonListPage> {
  var hobby;
  var hobbylist = [];
  bool nochoice = false;

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hobby = prefs.getString('hobby') ?? '';
    hobbylist = hobby.split(',');
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 130) / 2;
    final double itemWidth = size.width / 2;

    return Scaffold(
      body: FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .where("hobby", arrayContainsAny: hobbylist)
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
                  primary: false,
                  padding: const EdgeInsets.all(5.0),
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  crossAxisCount: 2,
                  childAspectRatio: (itemWidth / itemHeight),
                  children: snapshot.data.docs.map((DocumentSnapshot document) {
                    String title = document.data()['title'];
                    String imageURL = document.data()['imageURL'];
                    String headerURL = document.data()['headerURL'];
                    String commentText = document.data()['comment'];
                    List hobbylist = document.data()['hobby'];

                    return Hero(
                        tag: 'list' + title,
                        child: GestureDetector(
                          child:
                              HomeTile(title, imageURL, commentText, hobbylist),
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
            );
          } else {
            return Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
