import 'package:app_pos/pages/home/home_screen.dart';
import 'package:app_pos/screens/receipts_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_pos/constant.dart';
import 'package:flutter/material.dart';

const postcloud =
    'https://media.licdn.com/dms/image/C4E0BAQFD462Hv9r2vg/company-logo_200_200/0/1630575315482?e=1717027200&v=beta&t=kGp1P603iskkGc_4a4UrDwKfV-jI2AG3Wh8kjIlgaVc';

enum DrawerSelectedItem { sales, receipts, settings, backOffice, support }

class NavigationDrawerCustom extends StatelessWidget {
  const NavigationDrawerCustom({super.key, required this.selectedKey});
  final DrawerSelectedItem selectedKey;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                DrawerHeader(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(postcloud, height: 100),
                      const Text("PostCloud")
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Sales'),
                  selected: selectedKey == DrawerSelectedItem.sales,
                  leading: const Icon(
                    Icons.shopping_bag,
                    size: 30,
                  ),
                  onTap: () {
                    if (selectedKey == DrawerSelectedItem.sales) return;
                    context.go(HomeScreen.path);
                  },
                ),
                ListTile(
                  title: const Text('Receipts'),
                  selected: selectedKey == DrawerSelectedItem.receipts,
                  leading: const Icon(
                    Icons.description_outlined,
                    size: 30,
                  ),
                  onTap: () {
                    if (selectedKey == DrawerSelectedItem.receipts) return;
                    context.go(ReceiptsScreen.path);
                  },
                ),
                ListTile(
                  title: const Text('Settings'),
                  selected: selectedKey == DrawerSelectedItem.settings,
                  leading: const Icon(
                    Icons.settings,
                    size: 30,
                  ),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Back office'),
                  selected: selectedKey == DrawerSelectedItem.backOffice,
                  leading: const Icon(Icons.bar_chart),
                  onTap: () async {
                    await _launchURL();
                  },
                ),
                ListTile(
                  title: const Text('Support'),
                  selected: selectedKey == DrawerSelectedItem.support,
                  leading: const Icon(Icons.support_agent_outlined),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const ListTile(
            title: Text('Exit'),
            leading: Icon(Icons.exit_to_app_sharp),
          )
        ],
      ),
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
