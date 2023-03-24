import 'package:flutter_test/flutter_test.dart';
import 'package:kernel_plugin/kernel_plugin.dart';
import 'package:kernel_plugin/kernel_plugin_platform_interface.dart';
import 'package:kernel_plugin/kernel_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockKernelPluginPlatform
    with MockPlatformInterfaceMixin
    implements KernelPluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> startKernel(String cmd, String args) {
    throw UnimplementedError();
  }

  @override
  Future<int?> sum(int num1, int num2) {
    throw UnimplementedError();
  }
}

void main() {
  final KernelPluginPlatform initialPlatform = KernelPluginPlatform.instance;

  test('$MethodChannelKernelPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelKernelPlugin>());
  });

  test('getPlatformVersion', () async {
    KernelPlugin kernelPlugin = KernelPlugin();
    MockKernelPluginPlatform fakePlatform = MockKernelPluginPlatform();
    KernelPluginPlatform.instance = fakePlatform;

    expect(await kernelPlugin.getPlatformVersion(), '42');
  });
}
