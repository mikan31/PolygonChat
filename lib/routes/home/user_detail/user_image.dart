import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UserImage extends StatelessWidget {
  UserImage(this.userimage);
  String userimage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 7),
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.fill,
          image: userimage.isNotEmpty
              ? NetworkImage(userimage)
              : AssetImage('assets/preimage.JPG'),
        ),
      ),
    );
  }
}
