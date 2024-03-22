import 'package:flutter/material.dart';
import 'package:app_pos/widgets/keyboard_key.dart';

class CustomKeyboard extends StatefulWidget {
  @override
  _CustomKeyboardState createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard> {
  //
  late List<List<dynamic>> keys;
  late String amount;

  renderKeyboard() {
    return keys
        .map(
          (x) => Row(
            children: x.map(
              (y) {
                return Expanded(
                  child: KeyboardKey(
                    label: y,
                    value: y,
                    onTap: (val) {
                      print(val);
                      if (val is Widget) {
                        onBackSpacePress();
                      } else {
                        onKeyTap(val);
                      }
                    },
                  ),
                );
              },
            ).toList(),
          ),
        )
        .toList();
  }

  renderAmount() {
    String display = 'Enter a Number';
    TextStyle style = TextStyle(
      fontSize: 30,
      color: Colors.blueGrey,
    );

    if (this.amount.length > 0) {
      display = amount;

      // NumberFormat f = NumberFormat('#,###');

      // display = f.format(int.parse(amount));

      style = style.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      );
    }

    return Expanded(
      child: Center(
        child: Text(
          display,
          style: style,
        ),
      ),
    );
  }

  renderConfirmButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green, // Define el color de fondo del botón
                ),
                onPressed: amount.length > 0
                    ? () {
                        print(amount);
                      }
                    : null,
                child: Center(
                  child: Text(
                    'Confirm',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  onKeyTap(val) {
    setState(() {
      amount = amount + val;
    });
  }

  onBackSpacePress() {
    if (amount.length == 0) {
      return;
    }

    setState(() {
      amount = amount.substring(0, amount.length - 1);
    });
  }

  @override
  void initState() {
    super.initState();
    //
    keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['00', '0', Icon(Icons.keyboard_backspace, size: 45)],
    ];

    amount = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Custom Keyboard'),
      // ),
      body: SafeArea(
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          renderAmount(),
          ...renderKeyboard(),
          renderConfirmButton(),
        ]),
      ),
    );
  }
}
