import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sample/paira/paira.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat.dart';

class Chatroom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatroomPage(),
    );
  }
}

// ignore: must_be_immutable
class ChatroomPage extends StatelessWidget {
  String username = '';
  String usermail = '';
  String userimage = '';
  bool showpaira;

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('name') ?? '';
    usermail = prefs.getString('mail') ?? '';
    userimage = prefs.getString('image') ?? '';
    showpaira = prefs.getBool('showpaira') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(68, 114, 196, 1.0),
          elevation: 0,
          title: Text(
            "トーク",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: Container(),
        ),
        body: FutureBuilder(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('room')
                      .where("member", arrayContainsAny: [username])
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/background.jpg'),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        new ListView(
                          //padding: const EdgeInsets.all(8),
                          children: snapshot.data.docs
                              .map((DocumentSnapshot document) {
                            return Card(
                              child: Tile(
                                  roomMember: document.data()['member'],
                                  block: document.data()['block'],
                                  blockuser: document.data()['blockuser'],
                                  name: username,
                                  lastMessage: document.data()['lastMessage']),
                            );
                          }).toList(),
                        ),
                        showpaira ? Paira() : SizedBox(),
                      ],
                    );
                  });
            } else {
              return Container(
                decoration: new BoxDecoration(color: Colors.white),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class Tile extends StatelessWidget {
  final List roomMember;
  final bool block;
  final List blockuser;
  final String name;
  final String lastMessage;
  Tile(
      {Key key,
      this.roomMember,
      this.name,
      this.block,
      this.blockuser,
      this.lastMessage})
      : super(key: key);

  compstring(String a, String b) {
    if (a.compareTo(b) == 1) {
      return b + a;
    } else if (a.compareTo(b) == -1) {
      return a + b;
    } else {
      print("user name error");
    }
  }

  removelist(List data, String name) {
    data.remove(name);
    return data[0].toString();
  }

  Future<String> getUrl(String username) async {
    DocumentSnapshot docSnapshot =
        await FirebaseFirestore.instance.collection('user').doc(username).get();

    Map<String, dynamic> record = docSnapshot.data();
    return record['imageURL'];
  }

  @override
  Widget build(BuildContext context) {
    final String chatcompName = removelist(roomMember, name);

    return FutureBuilder(
        future: getUrl(chatcompName),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.20,
              child: Container(
                color: Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (snapshot.data != "")
                        ? NetworkImage(snapshot.data)
                        : AssetImage('assets/preimage.JPG'),
                    backgroundColor: Colors.white,
                  ),
                  title: Text(chatcompName),
                  subtitle: (lastMessage == null)
                      ? Text("")
                      : Text(lastMessage, overflow: TextOverflow.ellipsis),
                  onTap: () => {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Chat(
                          opponent: chatcompName,
                          room: compstring(name, chatcompName),
                          block: block,
                          blockuser: blockuser,
                          chatcompUrl: snapshot.data,
                        ),
                      ),
                    ),
                  },
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
