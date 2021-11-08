# advanced_page_turn
[![Flutter Community: page_turn](https://fluttercommunity.dev/_github/header/page_turn)](https://github.com/fluttercommunity/community)

# Advanced Page Turn Widget


Add a advanced page turn effect to widgets in your app.

Created by Subhash Shukla [@slightfoot](https://github.com/subhashDev121)


## Example

```dart
import 'package:flutter/material.dart';
import 'package:advanced_page_turn/advanced_page_turn.dart';

class HomeScreen extends StatefulWidget {


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = GlobalKey<AdvancedPageTurnState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvancedPageTurn(
        key: _controller,
        backgroundColor: Colors.white,
        showDragCutoff: false,
        lastPage: Container(child: Center(child: Text('Last Page!'))),
        children: <Widget>[
          for (var i = 0; i < 20; i++) PageView(page: i),
        ],
        initialIndex: 0,
        onPageChanged: (int currentPage){
          print("current page callback $currentPage");
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          _controller.currentState!.goToPage(2);
        },
      ),
    );
  }
}



```
