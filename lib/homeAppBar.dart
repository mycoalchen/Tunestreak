import 'package:flutter/material.dart';
import 'constants.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {

  AppBar appBar = new AppBar();

  final String? title;
  HomeAppBar({@required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: () => print('me tapped'),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Container(
              width: 40.0,
              height: 40.0,
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.all(0),
              decoration: circleInkwellBoxDecoration,
              child: const CircleAvatar(
                backgroundColor: circleColor,
                // TODO: backgroundImage
              ),
            ),
          ),
          Text(
            title ?? 'No title given',
            style: const TextStyle(
              color: darkGray,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const CircleAvatar(
            backgroundColor: circleColor,
            child: Icon(
              Icons.more_horiz,
              color: darkGray,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}