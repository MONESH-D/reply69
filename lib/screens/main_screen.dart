import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notification/screens/Matches.dart';
import 'package:notification/screens/profile.dart';
import 'package:notification/util/state.dart';
import 'package:notification/util/state_widget.dart';


import 'chats.dart';
import 'groups.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController _pageController;
  StateModel appState;  
  int _page = 1;

  @override
  Widget build(BuildContext context) {
            appState = StateWidget.of(context).state;
    final userId = appState?.firebaseUserAuth?.uid ?? '';
    final email = appState?.firebaseUserAuth?.email ?? '';

    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: <Widget>[
          // ChatsOld(),
          // Home(),
           DisplayMatches(uId: userId, uEmailId: email,),
          Chats(uId: userId, uEmailId: email,),
          // Notifications(),
          Profile(),
        ],
      ),

      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
          canvasColor: Theme.of(context).primaryColor,
          // sets the active color of the `BottomNavigationBar` if `Brightness` is light
          primaryColor: Theme.of(context).accentColor,
          textTheme: Theme
              .of(context)
              .textTheme
              .copyWith(caption: TextStyle(color: Colors.grey[500]),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            //  BottomNavigationBarItem(
            //   icon: Icon(
            //     Icons.check,
            //   ),
            //   title: Container(height: 0.0),
            // ),
            
            // BottomNavigationBarItem(
            //   icon: Icon(
            //     Icons.home,
            //   ),
            //   title: Container(height: 0.0),
            // ),
        
            BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.calendarAlt,
              ),
              title: Text("Schedule"),
            ),

           
            BottomNavigationBarItem(
              icon: Icon(
                Icons.message,
              ),
              title: Text("Chats"),
            ),
            

            // BottomNavigationBarItem(
            //   icon: IconBadge(
            //     icon: Icons.notifications,
            //   ),
            //   title: Container(height: 0.0),
            // ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
              ),
              title: Text("Profile"),
            ),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),
      ),
    );
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }
}