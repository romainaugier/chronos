// SPDX-License-Identifier: BSD-3-Clause 
// Copyright (c) 2026 - Present Romain Augier 
// All rights reserved. 

#include "chronos/common.hpp"

#if defined(CHRONOS_WIN)
#include <windows.h>
#endif // defined(CHRONOS_WIN) 

/*
   lib_entry is executed on dlopen / LoadLibrary
   lib_exit is executed on dlclose / FreeLibrary
*/

static void CHRONOS_LIB_ENTRY lib_entry(void) {}

static void CHRONOS_LIB_EXIT lib_exit(void) {}

#if defined(CHRONOS_WIN)
CHRONOS_CPP_ENTER

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
    CHRONOS_UNUSED(hModule);
    CHRONOS_UNUSED(lpReserved);

    switch(ul_reason_for_call)
    {
        case DLL_PROCESS_ATTACH:
            lib_entry();
            break;
        case DLL_THREAD_ATTACH:
            break;
        case DLL_THREAD_DETACH:
            break;
        case DLL_PROCESS_DETACH:
            lib_exit();
            break;
    }

    return TRUE;
}

CHRONOS_CPP_END
#endif // defined(CHRONOS_WIN) 
