
//==============================================================================
//
//   stdafx.h
//
//==============================================================================
//  Copyright (C) Guilaume Plante 2020 <cybercastor@icloud.com>
//==============================================================================

#ifndef __STDAFX12_F__
#define __STDAFX12_F__

#include "targetver.h"
#include <stdio.h>
#include <tchar.h>

#pragma warning( disable : 4702 )		// unreachable code
#pragma warning( disable : 4100 )		// unreferenced formal parameter
#pragma warning( disable : 4189 )		// local variable is initialized but not referenced
#pragma warning( disable : 4127 )		// conditional expression is constant
#pragma warning( disable : 4996 )		//
#pragma warning( disable : 4244 )		//
#pragma warning( disable : 4018 )		// 
#pragma warning( disable : 4311 )		//
#pragma warning( disable : 4477 )		//
#pragma warning( disable : 4068 )		// 
#pragma warning( disable : 4302 )		//
#pragma warning( disable : 4800 )

#ifdef PLATFORM_PC
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <winsock2.h>
#endif // PLATFORM_PC

# define MODULEDLL_API __declspec(dllexport)

#include <cstdio>
#include <iostream>




#endif//__STDAFX12_F__