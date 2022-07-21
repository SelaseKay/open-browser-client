import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'env.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Open Browser'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _controller;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    connectSocket();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    socket.disconnect();
    super.dispose();
  }

  void connectSocket() {
    try {
      socket = IO.io('http://$myLocalHostIP:3000', <String, dynamic>{
        "transports": ["websocket"],
        "autoConnect": false,
      });
      socket.connect();

      socket.onConnect((data) => debugPrint("Socket connected"));

      socket.on("disconnect", (data) {
        debugPrint('Socket disconnected');
      });
    } catch (e) {
      debugPrint("error occured: ${e.toString()}");
    }
  }

  void sendLink() {
    socket.emit('link', {"link": _controller.text.trim()});
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter link',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: MaterialButton(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  onPressed: () {
                    if (_controller.text.isEmpty) {
                      return;
                    }
                    sendLink();
                  },
                  child: const Text(
                    "Open Link",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
