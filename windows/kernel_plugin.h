#ifndef FLUTTER_PLUGIN_KERNEL_PLUGIN_H_
#define FLUTTER_PLUGIN_KERNEL_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace kernel_plugin {

class KernelPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  KernelPlugin();

  virtual ~KernelPlugin();

  // Disallow copy and assign.
  KernelPlugin(const KernelPlugin&) = delete;
  KernelPlugin& operator=(const KernelPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace kernel_plugin

#endif  // FLUTTER_PLUGIN_KERNEL_PLUGIN_H_
