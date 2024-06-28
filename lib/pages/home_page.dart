import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_bar.dart';
import 'package:flutter_application_1/components/logout_icon.dart';
import 'package:flutter_application_1/components/nav_bar.dart';
import 'package:flutter_application_1/components/notification_icon.dart';
import 'package:flutter_application_1/components/profile.dart';
import 'package:flutter_application_1/pages/notification_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selected = 0;
  final PageStorageBucket bucket = PageStorageBucket();

  void navigateBottomBar(int index) {
    setState(() {
      selected = index;
    });
  }

  final List<Widget> page = [
    // const HomeComponent(key: PageStorageKey('HomeComponent')),
    // const PlanningComponent(key: PageStorageKey('PlanningComponent')),
    // const SearchComponent(key: PageStorageKey('SearchComponent')),
    // const MessageComponent(key: PageStorageKey('MessageComponent')),
    const ProfileUser(key: PageStorageKey('ProfileUser')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomBar(selected),
      backgroundColor: const Color(0xFFFFFFFF),
      bottomNavigationBar: CustomBottomBar(
        onTabChange: (index) => navigateBottomBar(index),
        selectedIndex: selected,
      ),
      body: PageStorage(
        bucket: bucket,
        child: IndexedStack(
          index: selected,
          children: page,
        ),
      ),
    );
  }

  PreferredSizeWidget buildCustomBar(int selected) {
    switch (selected) {
      case 0:
        return CustomBar(
          leftWidget: const Text(" "),
          rightWidget: NotificationIcon(
            notificationExistence: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationHomePage()),
              );
            },
          ),
        );
      case 1:
        return const CustomBar(
          leftWidget: Text(
            "...",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerWidget1: Text(
            "Planning",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          rightWidget: NotificationIcon(notificationExistence: false),
        );
      case 2:
        return const CustomBar(
          leftWidget: Text('    '),
          rightWidget: NotificationIcon(notificationExistence: true),
        );
      case 3:
        return const CustomBar(
          leftWidget: Text(
            "          ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerWidget1: Text(
            "Messages",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          // rightWidget: ComboIcon(),
          rightWidget: Text("Combo icon"),
        );
      case 4:
        return const CustomBar(
          centerWidget1: Text(
            "Profile",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          rightWidget: LogoutComponent(),
        );
      default:
        return const CustomBar(
          leftWidget: Text('     '),
          rightWidget: NotificationIcon(notificationExistence: false),
        );
    }
  }
}
