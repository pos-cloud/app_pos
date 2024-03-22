import 'package:app_pos/screens/home_screen.dart';
import 'package:app_pos/screens/receipts_screen.dart';
import 'package:app_pos/screens/setting_screen.dart';
import 'package:app_pos/screens/tickets_screen.dart';
import 'package:app_pos/widgets/navigation_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_pos/constant.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  static String path = '/main_screen';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentTab = 0;

  void handleScreenChanged(int selectedScreen) {
    print(selectedScreen);
    setState(() {
      currentTab = selectedScreen;
    });
  }

  List screens = [
    HomeScreen(),
    ReceiptsScreen(),
    SettingScreen(),
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawerCustom(handleScreenChanged: handleScreenChanged),
      appBar: AppBar(
        title: Row(
          children: [
            DropdownButton<String>(
              value: 'one',
              items: const [
                DropdownMenuItem<String>(value: 'one', child: Text("one")),
              ],
              onChanged: (item) {},
            ),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => TicketScreen()));
              },
              child: Container(
                // color: Colors.red,
                height: 37,
                width: 40,
                child: Stack(
                  children: [
                    Positioned(
                      top: 14,
                      child: Icon(Icons.point_of_sale_sharp)),
                    Positioned(
                        // top: -10,
                        right:5,
                        child: Center(
                          child: Text('3',style: TextStyle(fontSize:16,fontWeight: FontWeight.bold),),
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.supervisor_account)),
          PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                        child: ListTile(
                      title: Text('Refesh'),
                      leading: Icon(Icons.refresh),
                    ))
                  ])
        ],
      ),
      body: screens[currentTab],
    );
  }

  _launchURL() async {
    const url = urlBackOffice;
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }
}
