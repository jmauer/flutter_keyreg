import 'package:kontrolle_keyreg/pages/home/localization/app_localizations.dart';
import 'package:kontrolle_keyreg/pages/home/screens/dashboard/view/dashboard.dart';
import 'package:flutter/material.dart';

import 'package:kontrolle_keyreg/pages/home/screens/scanner/view/view.dart';
import 'package:kontrolle_keyreg/pages/home/screens/settings/settings.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentTab = 0;
  final List<Widget> screens = [Dashboard(), Scanner(), Settings()];
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = Dashboard();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        child: Icon(
          Icons.nfc_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          setState(() {
            currentScreen = Scanner();
            currentTab = 1;
          });
        },
        backgroundColor: Color(0xffE8761E),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 10,
          child: Container(
            height: 60,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MaterialButton(
                        minWidth: 40,
                        onPressed: () {
                          setState(() {
                            currentScreen = Dashboard();
                            currentTab = 0;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home,
                              color: currentTab == 0
                                  ? Color(0xffE8761E)
                                  : Colors.grey,
                            ),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('dashboard'),
                              style: TextStyle(
                                color: currentTab == 0
                                    ? Color(0xffE8761E)
                                    : Colors.grey,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Spacer(
                    flex: 3,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MaterialButton(
                        minWidth: 40,
                        onPressed: () {
                          setState(() {
                            currentScreen = Settings();
                            currentTab = 2;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.settings,
                              color: currentTab == 2
                                  ? Color(0xffE8761E)
                                  : Colors.grey,
                            ),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('settings'),
                              style: TextStyle(
                                color: currentTab == 2
                                    ? Color(0xffE8761E)
                                    : Colors.grey,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Spacer()
                ]),
          )),
    );
  }
}
