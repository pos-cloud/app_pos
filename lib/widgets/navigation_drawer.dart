import 'package:url_launcher/url_launcher.dart';
import 'package:app_pos/constant.dart';
import 'package:flutter/material.dart';

class NavigationDrawerCustom extends StatelessWidget {
  final Function handleScreenChanged;
  const NavigationDrawerCustom({super.key, required this.handleScreenChanged});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
              child: ListView(
            children: [
              Image.network(
                'https://media.licdn.com/dms/image/C4E0BAQFD462Hv9r2vg/company-logo_200_200/0/1630575315482?e=1717027200&v=beta&t=kGp1P603iskkGc_4a4UrDwKfV-jI2AG3Wh8kjIlgaVc',
                height: 100,
              ),
              const Text("POS Cloud")
            ],
          )),
          ListTile(
            title: const Text('Sales'),
            selected: true,
            leading: const Icon(
              Icons.shopping_bag,
              size: 30,
            ),
            onTap: () {
              handleScreenChanged(0);
            },
          ),
          ListTile(
            title: const Text('Receipts'),
            selected: true,
            leading: const Icon(
              Icons.description_outlined,
              size: 30,
            ),
            onTap: () {
              handleScreenChanged(1);
            },
          ),
          ListTile(
            title: const Text('Settings'),
            selected: true,
            leading: const Icon(
              Icons.settings,
              size: 30,
            ),
            onTap: () {
              handleScreenChanged(2);
            },
          ),
          ListTile(
            title: const Text('Back office'),
            selected: true,
            leading: const Icon(Icons.bar_chart),
            onTap: () async {
              await _launchURL();
            },
          ),
          ListTile(
              title: const Text('Support'),
              selected: true,
              leading: const Icon(Icons.support_agent_outlined),
              onTap: () {
                handleScreenChanged(4);
              }),
          const Spacer(),
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
