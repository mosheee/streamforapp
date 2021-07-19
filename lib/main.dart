import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List groupsForUi = [];
  int nextGroup = 1;
  final List keepingTheGroupsFromServer = [
    [1, 2, 3, 4, 5],
    [6, 7, 8],
    [9, 10, 11, 12]
  ];
  Future<String>? _future;
  // ignore: close_sinks
  StreamController? _streamControllerForUi;
  Stream? _streamForUi;

  Future<String> initialDataFromServer() {
    return Future.delayed(Duration(seconds: 3)).then((value) {
      for (int oneGroup in keepingTheGroupsFromServer[0]) {
        groupsForUi.insert(0, oneGroup);
      }
      _streamControllerForUi!.add(groupsForUi.last);
      return 'first http request is complete';
    });
  }

  manageSwipe(bool swipe) {
    print('group number got $swipe');
    groupsForUi.removeLast();
    groupsForUi.isNotEmpty
        ? _streamControllerForUi!.add(groupsForUi.last)
        : _streamControllerForUi!.add('show circular');
  }

  callForMoreGroups() async {
    List<int> anotherListOfGroups =
        await Future.delayed(Duration(seconds: 3), () {
          print('future is done');
      return keepingTheGroupsFromServer[nextGroup];
    });
    bool updateUi = groupsForUi.isEmpty;
    for (int oneGroup in anotherListOfGroups) {
      groupsForUi.insert(0, oneGroup);
    }
    _streamControllerForUi!.add(groupsForUi.last);
    print(groupsForUi);
    nextGroup++;
  }

  @override
  void initState() {
    super.initState();
    _future = initialDataFromServer();
    _streamControllerForUi = StreamController();
    _streamForUi = _streamControllerForUi!.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return StreamBuilder(
                stream: _streamForUi,
                builder: (context, snap) {
                  print(snap.hasData);
                  print(snap.connectionState);
                  if (snap.hasData &&
                      snap.connectionState == ConnectionState.active) {
                    return Container(
                      height: 100,
                      width: 100,
                      color: Colors.blue,
                      child: ElevatedButton(
                        onPressed: () {
                          manageSwipe(true);
                          if (groupsForUi.length == 2) {
                            callForMoreGroups();
                          }
                        },
                        child: Text(snap.data!.toString()),
                      ),
                    );
                  }
                  // i need to know how the server is behave for sabtitute this condition in a more resonable one
                  if (snap.data == 'show circular') {
                    return CircularProgressIndicator();
                  }
                  return CircularProgressIndicator();
                },
              );
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
