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
  int nextGroup = 0;
  final List keepingTheGroupsFromServer = [
    [1, 2, 3, 4, 5],
    [6, 7],
    [8, 9, 10]
  ];
  // ignore: close_sinks
  StreamController? representStreamControllerFromServer;
  StreamSubscription? representStreamSubscriptionFromServer;
  //
  // ignore: close_sinks
  StreamController? _streamControllerForUi;
  Stream? _streamForUi;

  manageSwipe(bool swipe) {
    print('group number got $swipe');
    groupsForUi.removeLast();
    groupsForUi.isNotEmpty
        ? _streamControllerForUi!.add(groupsForUi.last)
        : _streamControllerForUi!.add(null);
  }

  @override
  void initState() {
    super.initState();
    // there are two stream :
    // 1 - stream that represent the stream from server
    // 2 - stream that manage the ui
    // ignore: close_sinks
    // this stream is represent the stream coming from the server
    representStreamControllerFromServer = StreamController();
    representStreamSubscriptionFromServer =
        representStreamControllerFromServer!.stream.listen((event) {
      if (event is List<int>) {
        bool? updateUi = groupsForUi.isEmpty;
        for (int group in event) {
          groupsForUi.insert(0, group);
        }
        updateUi ? _streamControllerForUi!.add(groupsForUi.last) : null;
//        _streamControllerForUi!.add(event);
      } else {
        print('event isnt list, event is : $event');
      }
    });

    _streamControllerForUi = StreamController();
    _streamForUi = _streamControllerForUi!.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: GestureDetector(
              child: Text(
                'add another group to list (function as the stream from server)',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                representStreamControllerFromServer!
                    .add(keepingTheGroupsFromServer[nextGroup]);
                // next line of code dont need to be used with the real serve
                nextGroup < 3 ? nextGroup++ : null;
              },
            ),
          ),
          StreamBuilder(
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
                    },
                    child: Text(snap.data!.toString()),
                  ),
                );
              }
              // i need to know how the server is behave for sabtitute this condition in a more resonable one
              if (snap.data == null) {
                return CircularProgressIndicator();
              }
              return CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}
