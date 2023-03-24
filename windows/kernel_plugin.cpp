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
//#include <variant>
//#include <iostream>
//#include <map>
#include <memory>
#include <sstream>

using namespace std;

const char kMenuSetMethod[] = "startKernel";

namespace kernel_plugin
{
	using flutter::EncodableMap;
	using flutter::EncodableValue;

	void startProcess1(string cmd, string args);

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
		if (method_call.method_name().compare("sum") == 0)
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
		if (method_call.method_name().compare(kMenuSetMethod) == 0) {
			const auto* arguments = std::get_if<flutter::EncodableList>(method_call.arguments());
			if (!arguments)
			{
				result->Error("no param");
				return;
			}
			auto pathStr = arguments->at(0);
			string path = get<string>(pathStr);
			auto argsStr = arguments->at(1);
			string args = get<string>(argsStr);
			//string cmd = path + " " + args;
			// cout << cmd << endl;


			// system(cmd.c_str());
			cout << "1t" << endl;
			thread t(startProcess1, path, args);
			cout << "2t" << endl;
			t.detach();
			result->Success(flutter::EncodableValue("startKernel"));
		}
		else
		{
			result->NotImplemented();
		}
	}

	void startProcess1(string cmd, string args) {
		std::string result = cmd + " " + args;
		system(result.c_str());
		//STARTUPINFO si = { sizeof(si) };
		//PROCESS_INFORMATION pi;
		//DWORD exitCode;

		//ZeroMemory(&si, sizeof(si));
		//si.cb = sizeof(si);
		//ZeroMemory(&pi, sizeof(pi));

		//// 调用CreateProcess启动后台进程
		//// string cmd = path + " " + args;
		////TCHAR szCommandLine[] = TEXT(*(cmd.c_str()));
		//cout << "3t" << endl;
		//BOOL bResult;
		//// (LPWSTR)cmd.c_str() (LPWSTR)cmd.c_str()  (LPWSTR)args.c_str()
		//string p = cmd + " " + args;
		//bResult = CreateProcess((LPCWSTR)cmd.c_str(),NULL , NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi);// &si, &pi
		//cout << cmd.c_str() << endl;
		//cout << args.c_str() << endl;
		//cout << p.c_str() << endl;
		//cout << "4t" << endl;
		//// 循环检测后台进程是否结束，如果结束则退出该线程
		//if (!bResult)
		//{
		//	// CreateProcess方法出现错误
		//	LPVOID lpMsgBuf;
		//	DWORD dw = GetLastError();

		//	FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER |
		//		FORMAT_MESSAGE_FROM_SYSTEM |
		//		FORMAT_MESSAGE_IGNORE_INSERTS,
		//		NULL,
		//		dw,
		//		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		//		(LPTSTR)&lpMsgBuf,
		//		0, NULL);

		//	// 打印错误信息
		//	MessageBox(NULL, (LPCTSTR)lpMsgBuf, TEXT("Error"), MB_OK | MB_ICONERROR);
		//	LocalFree(lpMsgBuf);
		//}

		//while (true) {
		//	if (GetExitCodeProcess(pi.hProcess, &exitCode)) {
		//		cout << "get exit" << endl;
		//		if (exitCode != STILL_ACTIVE) {
		//			break;
		//		}
		//	}
		//	else {
		//		// 获取进程退出码失败，处理错误
		//		cout << "GetExitCodeProcess error" << endl;
		//		// break;
		//	}
		//	// 睡眠一段时间，避免频繁检测和占用CPU资源
		//	Sleep(1000);
		//}
		//// 释放进程和线程的句柄
		//CloseHandle(pi.hProcess);
		//CloseHandle(pi.hThread);
	}

} // namespace kernel_plugin

