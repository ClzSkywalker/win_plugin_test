import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'kernel_plugin_platform_interface.dart';

/// An implementation of [KernelPluginPlatform] that uses method channels.
class MethodChannelKernelPlugin extends KernelPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('kernel_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<int?> sum(int num1, int num2) async {
    final result = await methodChannel.invokeMethod<int>('sum', [num1, num2]);
    return result;
  }

  @override
  Future<String?> startKernel(String cmd, String args) async {
    final result =
        await methodChannel.invokeMethod<String>('startKernel', [cmd, args]);
    return result;
  }

  @override
  Future<String?> startKernelMap(Map<String, Object> param) async {
    final result =
        await methodChannel.invokeMethod<String>('startKernelMap', param);
    return result;
  }
}
