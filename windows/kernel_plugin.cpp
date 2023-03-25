#include "kernel_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <string>
#include <thread>
#include <iostream>
#include <memory>
#include <sstream>

using namespace std;

const char kMenuSetMethod[] = "startKernel";
const char kMenuSetMethodMap[] = "startKernelMap";

namespace kernel_plugin
{
	using flutter::EncodableMap;
	using flutter::EncodableValue;

	void startMyKernel(string cmd, string args);

	// static
	void KernelPlugin::RegisterWithRegistrar(
		flutter::PluginRegistrarWindows* registrar)
	{
		auto channel =
			std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
				registrar->messenger(), "kernel_plugin",
				&flutter::StandardMethodCodec::GetInstance());

		auto plugin = std::make_unique<KernelPlugin>();

		channel->SetMethodCallHandler(
			[plugin_pointer = plugin.get()](const auto& call, auto result)
			{
				plugin_pointer->HandleMethodCall(call, std::move(result));
			});

		registrar->AddPlugin(std::move(plugin));
	}

	KernelPlugin::KernelPlugin() {}

	KernelPlugin::~KernelPlugin() {}

	void KernelPlugin::HandleMethodCall(
		const flutter::MethodCall<flutter::EncodableValue>& method_call,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
	{
		if (method_call.method_name().compare("getPlatformVersion") == 0)
		{
			std::ostringstream version_stream;
			version_stream << "Windows ";
			if (IsWindows10OrGreater())
			{
				version_stream << "10+";
			}
			else if (IsWindows8OrGreater())
			{
				version_stream << "8";
			}
			else if (IsWindows7OrGreater())
			{
				version_stream << "7";
			}
			result->Success(flutter::EncodableValue(version_stream.str()));
		}
		else if (method_call.method_name().compare("sum") == 0)
		{
			const auto* arguments = std::get_if<flutter::EncodableList>(method_call.arguments());
			if (!arguments)
			{
				result->Error("no param");
				return;
			}

			auto num1a = arguments->at(0);
			auto num2a = arguments->at(1);
			int num1 = get<int>(num1a);
			int num2 = get<int>(num2a);
			int num3 = num1 + num2;
			result->Success(flutter::EncodableValue(num3));
		}
		else if (method_call.method_name().compare(kMenuSetMethod) == 0) {
			const auto* arguments = std::get_if<flutter::EncodableList>(method_call.arguments());
			if (!arguments)
			{
				result->Error("arguments error");
				return;
			}
			auto pathStr = arguments->at(0);
			string path = get<string>(pathStr);
			auto argsStr = arguments->at(1);
			string args = get<string>(argsStr);
			thread t(startMyKernel, path, args);
			t.detach();
			result->Success(flutter::EncodableValue("startKernel"));
		}
		else if (method_call.method_name().compare(kMenuSetMethodMap) == 0) {
			auto* arguments = get_if<flutter::EncodableMap>(method_call.arguments());
			if (!arguments)
			{
				cout << "error err" << endl;
				cout << arguments << endl;
				result->Error("arguments error");
				return;
			}
			auto* path = std::get_if<string>(&(arguments->find(flutter::EncodableValue("cmd"))->second));
			auto* args = std::get_if<string>(&(arguments->find(flutter::EncodableValue("args"))->second));
			cout << *path << endl;
			cout << *args << endl;
			thread t1(startMyKernel, *path, *args);
			t1.detach();
			result->Success(flutter::EncodableValue("startKernelMap"));
		}
		else
		{
			result->NotImplemented();
		}
	}

	void startMyKernel(string exePath, string args) {
		// /K 参数用于保持后台运行
		std::string cmd = "/K " + exePath + " " + args;

		// 窗口
		STARTUPINFO si = { sizeof(si) };
		PROCESS_INFORMATION pi;

		ZeroMemory(&si, sizeof(si));
		si.cb = sizeof(si);
		ZeroMemory(&pi, sizeof(pi));
		si.dwFlags = STARTF_USESHOWWINDOW;
		si.wShowWindow = SW_HIDE;

		// 将string转为wchar_t*
		int len = MultiByteToWideChar(CP_UTF8, 0, cmd.c_str(), -1, NULL, 0);
		wchar_t* wstr = new wchar_t[len];
		MultiByteToWideChar(CP_UTF8, 0, cmd.c_str(), -1, wstr, len);
		std::wcout << wstr;

		// 可用下面命令直接替换wstr的位置
		// TEXT("D:\\project\\go\\event_shop_kernel\\output\\windows\\kernel.exe api --port=6905 --mode=test --dbPath=C:\\Users\\Administrator\\Documents\\event_shop\\databases\\todo_shop.db --logPath=C:\\Users\\Administrator\\Documents\\event_shop\\logs")
		// bResult用于判断创建进程是否成功
		BOOL bResult;
		bResult = CreateProcess(TEXT("C:\\Windows\\System32\\cmd.exe"), wstr, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi);
		// 检测是否成功启动，未启动则弹窗错误信息
		if (!bResult)
		{
			// CreateProcess方法出现错误
			LPVOID lpMsgBuf;
			DWORD dw = GetLastError();
			cout << dw << endl;

			FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER |
				FORMAT_MESSAGE_FROM_SYSTEM |
				FORMAT_MESSAGE_IGNORE_INSERTS,
				NULL,
				dw,
				MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
				(LPTSTR)&lpMsgBuf,
				0, NULL);

			// 弹窗错误信息
			MessageBox(NULL, (LPCTSTR)lpMsgBuf, TEXT("Error"), MB_OK | MB_ICONERROR);
			LocalFree(lpMsgBuf);

			CloseHandle(pi.hProcess);
			CloseHandle(pi.hThread);
		}
		// 释放内存
		delete[] wstr;
		wstr = NULL;
	}
} // namespace kernel_plugin

