#include "include/kernel_plugin/kernel_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "kernel_plugin.h"

void KernelPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  kernel_plugin::KernelPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
