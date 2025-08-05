import 'package:flutter/material.dart';
import 'package:plantify/pages/diagnose/diagnose_page.dart';
import 'package:plantify/pages/home/home_page.dart';
import 'package:plantify/pages/identify/identify_page.dart';
import 'package:plantify/pages/profile/profile_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeCenter extends StatefulWidget {
  const HomeCenter({super.key,});

  @override
  State<HomeCenter> createState() => _HomeCenterState();
}

class _HomeCenterState extends State<HomeCenter> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    HomePage(),
    DiagnosePage(),
    IdentifyPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  void refreshMiniPlayer() {
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false, // chỉ tránh phía dưới
        child: Stack(
          children: [
            // Nền gradient tràn toàn bộ
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // BottomNavigationBar phía trên nền
            BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedLabelStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: _selectedIndex == 0
                      ? Image.asset('assets/images/home1.png', width: 30, height: 30)
                      : Image.asset('assets/images/home2.png', width: 30, height: 30),
                  label: AppLocalizations.of(context)!.home,
                ),
                BottomNavigationBarItem(
                  icon: _selectedIndex == 1
                      ? Image.asset('assets/images/diagnose1.png', width: 30, height: 30)
                      : Image.asset('assets/images/diagnose2.png', width: 30, height: 30),
                  label: AppLocalizations.of(context)!.diagnose,
                ),
                BottomNavigationBarItem(
                  icon: _selectedIndex == 2
                      ? Image.asset('assets/images/identify1.png', width: 30, height: 30)
                      : Image.asset('assets/images/identify2.png', width: 30, height: 30),
                  label: AppLocalizations.of(context)!.identify,
                ),
                BottomNavigationBarItem(
                  icon: _selectedIndex == 3
                      ? Image.asset('assets/images/profile1.png', width: 30, height: 30)
                      : Image.asset('assets/images/profile2.png', width: 30, height: 30),
                  label: AppLocalizations.of(context)!.profile,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}