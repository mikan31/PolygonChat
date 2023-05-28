import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sample/routes/home/user_detail/user_image.dart';

// ignore: must_be_immutable
class UserHeader extends StatelessWidget {
  UserHeader(this.userheader, this.userimage);
  String userheader;
  String userimage;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        userheader.isNotEmpty
            ? Image.network(userheader,
                height: size.height / 4, width: size.width, fit: BoxFit.fill)
            : Image.asset('assets/preheader.jpg',
                height: size.height / 4, width: size.width, fit: BoxFit.fill),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: UserImage(userimage),
          ),
        ),
      ],
    );
  }
}
