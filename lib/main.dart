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
  int nextGroup = 0;
  List groupsForUi = [];
  final List keepingTheGroupsFromServer = [
    [1, 2, 3, 4, 5],
    [6, 7],
    [8, 9, 10]
  ];
  // ignore: close_sinks
  StreamController? _streamControllerFromServer;
  StreamSubscription? _streamSubscriptionFromServer;
  //
  StreamController? _streamControllerForUi;
  Stream? _streamForUi;

  manageSwipe() {
    print('group number got like/unlike');
    groupsForUi.removeLast();
    groupsForUi.isNotEmpty
        ? _streamControllerForUi!.add(groupsForUi.last)
        : _streamControllerForUi!.add(null);
  }

  @override
  void initState() {
    super.initState();
    // stream how recive events from stream server and from swipe manage the data and send event
    // to the ui stream
    // one stream cant handle the data from server and the ui becouse they act like two different pipes
    // one pipe is getting data from server and manageing it on client side
    // second pipe getting the data from the first pipe after the data was managed and then update the ui

    // ignore: close_sinks
    // this stream is getting event from swipe and from server
    _streamControllerFromServer = StreamController();
    _streamSubscriptionFromServer =
        _streamControllerFromServer!.stream.listen((event) {
      if (event is List<int>) {
        bool updateUi = groupsForUi.isEmpty;
        for (int group in event) {
          groupsForUi.insert(0, group);
        }
        updateUi ? _streamControllerForUi!.add(groupsForUi.last) : null;
//        _streamControllerForUi!.add(event);
      } else if (event is bool) {
        // update the ui
        print('group number got like/unlike');
        groupsForUi.removeLast();
        groupsForUi.isNotEmpty
            ? _streamControllerForUi!.add(groupsForUi.last)
            : _streamControllerForUi!.add(null);
      } else {
        print('event isnt bool or list, event is : $event');
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
                _streamControllerFromServer!
                    .add(keepingTheGroupsFromServer[nextGroup]);
                // next line of code dont need to be used with the real server
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
                      _streamControllerFromServer!.add(true);
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
