import 'package:flutter/material.dart';
import 'constants.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {

  AppBar appBar = new AppBar();

  var circleColor = Color.fromRGBO(200, 200, 200, 1);
  final String? title;
  HomeAppBar({@required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: circleColor,
            child: const Icon(
              Icons.search,
              color: darkGray,
            ),
          ),
          const SizedBox(
            width: 30,
          ),
          Text(
            title ?? 'No title given',
            style: const TextStyle(
              color: darkGray,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: circleColor,
          // TODO: Snap bitmoji here backgroundImage: NetworkImage()
        ),
      ),
      actions: <Widget>[
        CircleAvatar(
          backgroundColor: circleColor,
          child: const Icon(
            Icons.person_add,
            color: darkGray,
          ),
        ),
        const SizedBox(width: 6),
        CircleAvatar(
          backgroundColor: circleColor,
          child: const Icon(
            Icons.settings,
            color: darkGray,
          ),
        ),
        const SizedBox(
          width: 5,
        )
      ]
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}