
//==============================================================================
//
//     main.cpp
//
//============================================================================
//  Copyright (C) Guilaume Plante 2020 <cybercastor@icloud.com>
//==============================================================================



#include "stdafx.h"
#include "windows-api-ex.h"
#include "cmdline.h"
#include "Shlwapi.h"

#include <codecvt>
#include <locale>
#include <vector>
#include <unordered_map>
#include <iterator>
#include <regex>
#include <filesystem>

#pragma message( "Compiling " __FILE__ )
#pragma message( "Last modified on " __TIMESTAMP__ )



#define DOMAINLOCAL  TEXT("desktop-lk1v00r")
#define ADMIN_PASS  TEXT("MaMemoireEstMaCle7955")
#define ADMIN_USER  TEXT("Sysop")
#define COMMAND_POWERSHELL5  TEXT("C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe")
#define COMMAND_PWSH  TEXT("C:\\\My_Apps\\Powershell\\7\\pwsh.exe")
#define COMMAND_MSWT  TEXT("C:\\Users\\radic\\AppData\\Local\\Microsoft\\WindowsApps\\wt.exe")
int main(int argc, TCHAR** argv)
{

#ifdef UNICODE
	const char ** argn = (const char **)C::Convert::allocate_argn(argc, argv);
#else
	char ** argn = argv;
#endif // UNICODE

	CmdLineUtil::getInstance()->initializeCmdlineParser(argc, argn);

	CmdlineParser *inputParser = CmdLineUtil::getInstance()->getInputParser();

	CmdlineOption cmdlineOptionHelp({    "-h", "--help"    }, "display this help");
	CmdlineOption cmdlineOptionVerbose({ "-v", "--verbose" }, "verbose output");
	CmdlineOption cmdlineOptionElevate({ "-e", "--elevate" }, "elevete account privileges to administrator when launching application");
	CmdlineOption cmdlineOptionListProcess({ "-l", "--list" }, "list the processes currently running");
	//CmdlineOption cmdlineOptionPassword({ "-d", "--all" }, "password (for the user defined with -u)");

	inputParser->addOption(cmdlineOptionHelp);
	inputParser->addOption(cmdlineOptionVerbose);
	inputParser->addOption(cmdlineOptionListProcess);
	inputParser->addOption(cmdlineOptionElevate);

	bool optHelp = inputParser->isSet(cmdlineOptionHelp);
	bool optVerbose = inputParser->isSet(cmdlineOptionVerbose);
	bool optListProcess = inputParser->isSet(cmdlineOptionListProcess);
	bool optElevate = inputParser->isSet(cmdlineOptionElevate);


	if (optElevate){
		if (C::Process::IsRunAsAdministrator()){
			std::cout << "The applicaiton is already running with admin privileges" << std::endl;
		}
		else{
			C::Process::ElevateNow();
		}
	}

	std::unordered_map<DWORD, std::string> ProcessList;

	DWORD bufferSize = MAX_PATH;
	TCHAR processname[MAX_PATH + 1], *stop;
	TCHAR fileExt[MAX_PATH + 1];
	TCHAR fileDir[MAX_PATH + 1];
	TCHAR fileName[MAX_PATH + 1];
	DWORD *processes, lpProcesses[QUITE_LARGE_NB_PROCESSES], bytes, processId;
	SIZE_T nbProcesses;
	HANDLE hProcess;
	processes = lpProcesses;

	nbProcesses = C::Process::FillProcessesList(&processes, sizeof(lpProcesses));
	if (!nbProcesses) {
		_PRINTF(_T("ERROR : Could not enumerate process list\n"));
		return -1;
	}
	
	if (optListProcess) {
		_PRINTF(_T("\t PROCESS LIST (%d)\n"), (int)nbProcesses);
		_PRINTF(_T("\t pid \t name \n"));
	}

	for (int i = 0; i < nbProcesses; i++) {
		hProcess = OpenProcess(PROCESS_QUERY_INFORMATION, FALSE, processes[i]);
		if (hProcess && C::Process::ProcessIdToName(processes[i], processname, bufferSize)) {
			std::string processnameDouble = std::regex_replace(processname, std::regex(R"(\\)"), R"(\\)");
			decomposePath(processnameDouble.c_str(), fileDir, fileName, fileExt);
			ProcessList[processes[i]] = fileName;
			if (optListProcess) {
				_PRINTF(_T("%\t %d \t %s \n"), processes[i], fileName);
			}
		}
	}

	// ...........

	return 0;
}
