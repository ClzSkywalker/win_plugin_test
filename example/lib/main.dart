import 'dart:convert';
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
  final kernelPlugin = KernelPlugin();
  var dir = await initPath();
  String args =
      "api --port=6905 --mode=test --dbPath=${dir.dbPath} --logPath=${dir.logPath}";
  String kernelPath =
      "D:\\project\\go\\event_shop_kernel\\output\\windows\\kernel.exe";
  await kernelPlugin.startKernel(kernelPath, args);
}

void startKernelMap(RootIsolateToken rootIsolateToken) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  final kernelPlugin = KernelPlugin();
  var dir = await initPath();
  String args =
      "api --port=6905 --mode=test --dbPath=${dir.dbPath} --logPath=${dir.logPath}";
  // String kernelPath =
  //     "D:\\project\\go\\event_shop_kernel\\output\\windows\\kernel.exe";
  String kernelPath = ".\\kernel.exe";
  Map<String, Object> param = {"cmd": kernelPath, "args": args};
  await kernelPlugin.startKernelMap(param);
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

    // try {
    //   RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    //   Isolate.spawn(startKernel, rootIsolateToken);
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    try {
      RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
      Isolate.spawn(startKernelMap, rootIsolateToken);
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

/// Find windows dll path.
String? findWindowsDllPath() {
  var location = findPackageLibPath(Directory.current.path);
  if (location == null) {
    // Try to handle when using global run
    // When using `global run` we might not be able to find the lib path.
    // Try from the script
    // when running using global run: file:///C:/oxxxdevx/git/github.com/tekartik/sqflite/packages/console_test_app/.dart_tool/pub/bin/sqflite_ffi_console_test_app/sqflite_ffi_simple_bin.dart-2.19.0.snapshot
    // when running normally:  C:\xxx\devx\git\github.com\tekartik\sqflite\packages\console_test_app\bin\sqflite_ffi_simple_bin.dart
    // When running hoster:  C:\Users\xxx\AppData\Local\Pub\Cache\bin\pubglobalupdate.bat
    try {
      // This the case when activated from path...ugly but worth trying.
      var projectPath = path.dirname(path.dirname(path
          .dirname(path.dirname(path.dirname(Platform.script.toFilePath())))));
      location = findPackageLibPath(projectPath);
    } catch (_) {}
  }
  if (location != null) {
    var pathStr = packageGetSqlite3DllPath(path.normalize(path.join(location)));
    return pathStr;
  }
  return null;
}

/// Get the dll path from our package path.
String packageGetSqlite3DllPath(String packagePath) {
  var pathStr = path.join(packagePath, 'src', 'windows', 'sqlite3.dll');
  return pathStr;
}

String? findPackageLibPath(String pathStr) {
  try {
    var map = pathGetPackageConfigMap(pathStr);
    var packagePath =
        pathPackageConfigMapGetPackagePath(pathStr, map, 'kernel_plugin');
    if (packagePath != null) {
      return path.join(packagePath, 'lib');
    }
  } catch (_) {}
  return null;
}

/// Read package_config.json
Map<String, Object?> pathGetPackageConfigMap(String packageDir) =>
    pathGetJson(path.join(packageDir, '.dart_tool', 'package_config.json'));

Map<String, Object?> pathGetJson(String path) {
  var content = File(path).readAsStringSync();
  try {
    return (jsonDecode(content) as Map).cast<String, Object?>();
  } catch (e) {
    print('error in $path $e');
    rethrow;
  }
}

/// Get a library path, you can get the project dir through its parent
String? pathPackageConfigMapGetPackagePath(
    String path, Map packageConfigMap, String package,
    {bool? windows}) {
  var packagesList = packageConfigMap['packages'] as Iterable;
  for (var packageMap in packagesList) {
    if (packageMap is Map) {
      var name = packageMap['name'];

      if (name is String && name == package) {
        var rootUri = packageMap['rootUri'];
        if (rootUri is String) {
          // rootUri if relative is relative to .dart_tool
          // we want it relative to the root project.
          // Replace .. with . to avoid going up twice
          if (rootUri.startsWith('..')) {
            rootUri = rootUri.substring(1);
          }
          return _toFilePath(path, rootUri, windows: windows);
        }
      }
    }
  }
  return null;
}

/// Build a file path.
String _toFilePath(String parent, String pathStr, {bool? windows}) {
  var uri = Uri.parse(pathStr);
  pathStr = uri.toFilePath(windows: windows);
  if (path.isRelative(pathStr)) {
    return path.normalize(path.join(parent, pathStr));
  }
  return path.normalize(pathStr);
}
