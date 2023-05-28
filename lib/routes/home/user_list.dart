import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sample/routes/home/home_grid/home_tile.dart';
import 'package:sample/routes/home/user_detail/user_detail.dart';

class UserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UserListPage(),
    );
  }
}

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 130) / 2;
    final double itemWidth = size.width / 2;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .orderBy('createdAt', descending: true)
          .limit(60)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return Container(
          child: GridView.count(
            // ignore: deprecated_member_use
            primary: false,
            padding: const EdgeInsets.all(5.0),
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            crossAxisCount: 2,
            childAspectRatio: (itemWidth / itemHeight),
            // ignore: deprecated_member_use
            children: snapshot.data.documents.map((DocumentSnapshot document) {
              String title = document.data()['title'];
              String imageURL = document.data()['imageURL'];
              String headerURL = document.data()['headerURL'];
              String commentText = document.data()['comment'];
              List hobbylist = document.data()['hobby'];

              return Hero(
                  tag: 'list' + title,
                  child: GestureDetector(
                    child: HomeTile(title, imageURL, commentText, hobbylist),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetail(title, imageURL,
                              headerURL, commentText, hobbylist),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                  ));
            }).toList(),
          ),
        );
      },
    );
  }
}
