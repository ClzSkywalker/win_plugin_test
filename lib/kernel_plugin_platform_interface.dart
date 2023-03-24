import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'kernel_plugin_method_channel.dart';

abstract class KernelPluginPlatform extends PlatformInterface {
  /// Constructs a KernelPluginPlatform.
  KernelPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static KernelPluginPlatform _instance = MethodChannelKernelPlugin();

  /// The default instance of [KernelPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelKernelPlugin].
  static KernelPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [KernelPluginPlatform] when
  /// they register themselves.
  static set instance(KernelPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int?> sum(int num1, int num2) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> startKernel(String cmd, String args) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
