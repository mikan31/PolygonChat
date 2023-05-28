import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sample/routes/home/home_grid/comment.dart';
import 'package:sample/routes/home/home_grid/image_circle.dart';
import 'package:sample/routes/home/home_grid/title_text.dart';

// ignore: must_be_immutable
class HomeTile extends StatelessWidget {
  HomeTile(this.title, this.imageURL, this.commentText, this.hobbylist);
  String title;
  String imageURL;
  String commentText;
  List hobbylist = [];
  List viewlist = [];
  int hobbylength;

  counthalf(String inputString) {
    int sum = 0;
    List testlist = inputString.split('');
    for (String i in testlist) {
      if (RegExp(r'^[a-zA-Z0-9!-/:-@¥[-`{-~]').hasMatch(i)) sum += 1;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    switch (hobbylist.length) {
      case 0:
        break;
      case 1:
        viewlist = [hobbylist[0]];
        hobbylength = hobbylist[0].length;
        break;
      default:
        viewlist = [hobbylist[0], hobbylist[1]];
        hobbylength = hobbylist[0].length + hobbylist[1].length;
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TitleText(title),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: ImageCircle(imageURL),
                ),
                Wrap(children: <Widget>[
                  for (var item in viewlist)
                    hobbylength <= 7
                        ? shortText(item)
                        : longText(item, context),
                ]),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Comment(commentText),
                ),
              ],
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage('assets/polygon.jpg'),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 1.0,
                    blurRadius: 10.0,
                    offset: Offset(7, 7) //偏り具合
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget shortText(String item) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        height: 30,
        decoration: BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.1),
          //border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                item,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget longText(String item, BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 5.5;

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        height: 30,
        width: itemWidth,
        decoration: BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.1),
          //border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  item,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
