import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'settings.dart';
import 'user_provider.dart';

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
              child: Provider.of<UserProvider>(context, listen: true).profilePicture,
            ),
          ),
          Text(
            title ?? 'No title given',
            style: titleTextStyle,
          ),
          InkWell(
            onTap: () =>
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.fromLTRB(6, 0, 6, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: const Text('Manage Friends'),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('Settings'),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Settings())
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ), 
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Container(
              width: 40.0,
              height: 40.0,
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.all(0),
              decoration: circleInkwellBoxDecoration,
              child: const Icon(
                Icons.more_horiz,
                color: darkGray,
              )
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}