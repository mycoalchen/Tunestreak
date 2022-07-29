import 'package:flutter/material.dart';
import 'package:tunestreak/home_app_bar.dart';
import 'add_friends.dart';
import 'send_song.dart';
import 'streaks.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Duration pageTurnDuration = const Duration(milliseconds: 300);
  Curve pageTurnCurve = Curves.ease;
  final PageController controller = PageController(initialPage: 0);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final List<BottomNavigationBarItem> homeNavBarItems =
      <BottomNavigationBarItem>[
    const BottomNavigationBarItem(
      icon: Icon(Icons.message),
      label: 'Friends',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.send),
      label: 'Send Song',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_add),
      label: 'Add Friends',
    ),
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      controller.jumpToPage(index);
    });
  }

  void _goForward() {
    if (_selectedIndex != homeNavBarItems.length - 1) {
      controller.nextPage(duration: pageTurnDuration, curve: pageTurnCurve);
    } else {
      controller.jumpToPage(0);
    }
  }

  void _goBack() {
    if (_selectedIndex != 0) {
      controller.previousPage(duration: pageTurnDuration, curve: pageTurnCurve);
    } else {
      controller.jumpToPage(homeNavBarItems.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = <Widget>[
      StreaksPage(
        openSendSong: _goForward,
      ),
      const SendSongPage(),
      const AddFriendsPage(),
    ];
    return Scaffold(
      appBar: HomeAppBar(
        title: homeNavBarItems[_selectedIndex].label,
      ),
      body: GestureDetector(
          onHorizontalDragEnd: (dragEndDetails) {
            if (dragEndDetails.primaryVelocity! < 0) {
              _goForward();
            } else if (dragEndDetails.primaryVelocity! > 0) {
              _goBack();
            }
          },
          child: PageView.builder(
              onPageChanged: (newPage) {
                setState(() {
                  _selectedIndex = newPage;
                });
              },
              itemCount: 3,
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Center(child: _pages.elementAt(_selectedIndex));
              })),
      bottomNavigationBar: BottomNavigationBar(
        items: homeNavBarItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
