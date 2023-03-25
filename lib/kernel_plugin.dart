import 'kernel_plugin_platform_interface.dart';

class KernelPlugin {
  Future<String?> getPlatformVersion() {
    return KernelPluginPlatform.instance.getPlatformVersion();
  }

  Future<int?> sum(int num1, int num2) {
    return KernelPluginPlatform.instance.sum(num1, num2);
  }

  Future<String?> startKernel(String cmd, String args) {
    return KernelPluginPlatform.instance.startKernel(cmd, args);
  }

  Future<String?> startKernelMap(Map<String, Object> param) async {
    return KernelPluginPlatform.instance.startKernelMap(param);
  }
}
