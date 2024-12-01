import 'package:app_pos/pages/home/bloc/home_bloc.dart';
import 'package:app_pos/pages/home/views/keyboard_screen.dart';
import 'package:app_pos/pages/home/widget/display_item.dart';
import 'package:app_pos/pages/navigation_drawer.dart';
import 'package:app_pos/widgets/article.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  static String path = '/main_screen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return HomeBloc();
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<HomeBloc, HomeBlocState>(
            builder: (context, state) {
              return Row(
                children: [
                  DropdownButton<String>(
                    value: 'one',
                    items: const [
                      DropdownMenuItem<String>(
                          value: 'one', child: Text("one")),
                    ],
                    onChanged: (item) {},
                  ),
                  const SizedBox(width: 10),
                  DisplayItems(numItems: state.selectedItems.length)
                ],
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.supervisor_account),
            ),
            PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                    child: ListTile(
                  title: Text('Refesh'),
                  leading: Icon(Icons.refresh),
                ))
              ],
            )
          ],
        ),
        drawer: const NavigationDrawerCustom(
          selectedKey: DrawerSelectedItem.sales,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: double.infinity,
                height: 100,
                color: Colors.blue[500],
                child: const Center(
                  child: Text(
                    '\$5439059430',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  label: const Text(
                    'Search',
                  ),
                  suffixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemBuilder: (context, index) => GestureDetector(
                    child: const Article(),
                    onTap: () async {
                      final bloc = context.read<HomeBloc>();
                      debugPrint(index.toString());
                      final numItems =
                          await context.push<int>(KeyboardScreen.path);
                      if (numItems == null || numItems <= 0) return;
                      bloc.addSelectedItem(numItems.toString());
                    }),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemCount: [1, 2, 3, 4, 5, 6, 7, 8].length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
