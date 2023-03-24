import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:kernel_plugin/kernel_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class Dir {
  String dbPath;
  String logPath;
  Dir({required this.dbPath, required this.logPath});
}

Future<Dir> initPath() async {
  var di = await getApplicationDocumentsDirectory();
  String dbPath = path.join(di.path, "event_shop", "databases");
  String logPath = path.join(di.path, "event_shop", "logs");
  var dbDir = Directory(dbPath);
  var logDir = Directory(logPath);
  dbDir.createSync(recursive: true);
  logDir.createSync(recursive: true);
  dbPath = path.join(dbPath, "todo_shop.db");
  Dir dir = Dir(dbPath: dbPath, logPath: logPath);
  return dir;
}

void startKernel(RootIsolateToken rootIsolateToken) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  final _kernelPlugin = KernelPlugin();
  var dir = await initPath();
  String args =
      "api --port=6905 --mode=test --dbPath=${dir.dbPath} --logPath=${dir.logPath}";
  String kernelPath =
      "D:\\project\\flutter\\kernel_plugin\\example\\windows\\flutter\\ephemeral\\.plugin_symlinks\\kernel_plugin\\windows\\assert\\kernel\\kernel.exe";
  await _kernelPlugin.startKernel(kernelPath, args);
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  int _sum = 0;
  final _kernelPlugin = KernelPlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _kernelPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    int sum = 0;
    try {
      sum = await _kernelPlugin.sum(2, 7) ?? 0;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    try {
      // ReceivePort rp1 = ReceivePort();
      RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
      Isolate.spawn(startKernel, rootIsolateToken);
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _sum = sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n sum:$_sum\n'),
        ),
      ),
    );
  }
}
