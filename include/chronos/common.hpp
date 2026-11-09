// SPDX-License-Identifier: BSD-3-Clause 
// Copyright (c) 2026 - Present Romain Augier 
// All rights reserved. 

#pragma once

#if !defined(__CHRONOS)
#define __CHRONOS

// Compiler detection 
// https://github.com/cpredef/predef/blob/master/Compilers.md 
// Clang defines __GNUC__ (and clang-cl defines _MSC_VER), so it must be tested first 
#if defined(__clang__)
#define CHRONOS_CLANG
#elif defined(_MSC_VER)
#define CHRONOS_MSVC
#elif defined(__GNUC__)
#define CHRONOS_GCC
#else
#error "Unsupported compiler"
#endif // defined(__clang__) 

#if defined(_MSC_VER)
#pragma warning(disable : 4711) // function selected for automatic inline expansion 
#if !defined(_CRT_SECURE_NO_WARNINGS)
#define _CRT_SECURE_NO_WARNINGS
#endif // !defined(_CRT_SECURE_NO_WARNINGS) 
#if !defined(_SILENCE_ALL_MS_EXT_DEPRECATION_WARNINGS)
#define _SILENCE_ALL_MS_EXT_DEPRECATION_WARNINGS
#endif // !defined(_SILENCE_ALL_MS_EXT_DEPRECATION_WARNINGS) 
#endif // defined(_MSC_VER) 

#define CHRONOS_STRIFY(x) #x
#define CHRONOS_STRIFY_MACRO(m) CHRONOS_STRIFY(m)

#if !defined(CHRONOS_VERSION_MAJOR)
#define CHRONOS_VERSION_MAJOR 0
#endif // !defined(CHRONOS_VERSION_MAJOR) 

#if !defined(CHRONOS_VERSION_MINOR)
#define CHRONOS_VERSION_MINOR 0
#endif // !defined(CHRONOS_VERSION_MINOR) 

#if !defined(CHRONOS_VERSION_PATCH)
#define CHRONOS_VERSION_PATCH 0
#endif //  !defined(CHRONOS_VERSION_PATCH) 

#if !defined(CHRONOS_VERSION_REVISION)
#define CHRONOS_VERSION_REVISION 0
#endif //  !defined(CHRONOS_VERSION_REVISION) 

#define CHRONOS_VERSION_STR                                                                          \
    CHRONOS_STRIFY_MACRO(CHRONOS_VERSION_MAJOR) "."                                                      \
    CHRONOS_STRIFY_MACRO(CHRONOS_VERSION_MINOR) "."                                                      \
    CHRONOS_STRIFY_MACRO(CHRONOS_VERSION_PATCH) "."                                                      \
    CHRONOS_STRIFY_MACRO(CHRONOS_VERSION_REVISION)

// Architecture detection 
// https://github.com/cpredef/predef/blob/master/Architectures.md 
#if defined(__x86_64__) || defined(_M_X64) || defined(_M_AMD64)
#define CHRONOS_X86_64
#define CHRONOS_SIZEOF_PTR 8
#define CHRONOS_ARCH_STR "X86_64"
#elif defined(__i386__) || defined(_M_IX86)
#define CHRONOS_X86
#define CHRONOS_SIZEOF_PTR 4
#define CHRONOS_ARCH_STR "X86"
#elif defined(__aarch64__) || defined(_M_ARM64) || defined(_M_ARM64EC)
#define CHRONOS_AARCH64
#define CHRONOS_SIZEOF_PTR 8
#define CHRONOS_ARCH_STR "AARCH64"
#elif defined(__arm__) || defined(_M_ARM)
#define CHRONOS_AARCH32
#define CHRONOS_SIZEOF_PTR 4
#define CHRONOS_ARCH_STR "AARCH32"
#else
#error "Unsupported architecture"
#endif // defined(__x86_64__) || defined(_M_X64) || defined(_M_AMD64) 

// Umbrella architecture macros 
#if defined(CHRONOS_X86_64) || defined(CHRONOS_X86)
#define CHRONOS_INTEL
#elif defined(CHRONOS_AARCH64) || defined(CHRONOS_AARCH32)
#define CHRONOS_ARM
#endif // defined(CHRONOS_X86_64) || defined(CHRONOS_X86) 

#if CHRONOS_SIZEOF_PTR == 8
#define CHRONOS_64BITS
#else
#define CHRONOS_32BITS
#endif // CHRONOS_SIZEOF_PTR == 8 

// Operating system detection 
// https://sourceforge.net/p/predef/wiki/OperatingSystems 
#if defined(_WIN32)
#define CHRONOS_WIN
#if !defined(WIN32_LEAN_AND_MEAN)
#define WIN32_LEAN_AND_MEAN
#endif // !defined(WIN32_LEAN_AND_MEAN) 
#if !defined(NOMINMAX)
#define NOMINMAX
#endif // !defined(NOMINMAX) 
#define CHRONOS_OS_STR "WIN"
#elif defined(__linux__)
#define CHRONOS_LINUX
#define CHRONOS_UNIX
#define CHRONOS_OS_STR "LINUX"
#elif defined(__APPLE__)
#define CHRONOS_APPLE
#define CHRONOS_UNIX
#define CHRONOS_OS_STR "APPLE"
#elif defined(__FreeBSD__)
#define CHRONOS_FREEBSD
#define CHRONOS_BSD
#define CHRONOS_UNIX
#define CHRONOS_OS_STR "FREEBSD"
#elif defined(__OpenBSD__)
#define CHRONOS_OPENBSD
#define CHRONOS_BSD
#define CHRONOS_UNIX
#define CHRONOS_OS_STR "OPENBSD"
#elif defined(__NetBSD__)
#define CHRONOS_NETBSD
#define CHRONOS_BSD
#define CHRONOS_UNIX
#define CHRONOS_OS_STR "NETBSD"
#elif defined(__DragonFly__)
#define CHRONOS_DRAGONFLY
#define CHRONOS_BSD
#define CHRONOS_UNIX
#define CHRONOS_OS_STR "DRAGONFLY"
#else
#error "Unsupported platform"
#endif // defined(_WIN32) 

#define CHRONOS_PLATFORM_STR CHRONOS_OS_STR "_" CHRONOS_ARCH_STR

#include <cassert>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>

#define CHRONOS_LIBC(fn) std::fn

// ssize_t 
#if defined(CHRONOS_UNIX) || defined(__MINGW32__)
#include <sys/types.h>
#elif defined(CHRONOS_WIN) && !defined(_SSIZE_T_DEFINED)
#define _SSIZE_T_DEFINED
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#endif // defined(CHRONOS_UNIX) || defined(__MINGW32__) 

// Byte order 
#define CHRONOS_BYTE_ORDER_LITTLE_ENDIAN 1234
#define CHRONOS_BYTE_ORDER_BIG_ENDIAN 4321

#if defined(__BYTE_ORDER__) && defined(__ORDER_LITTLE_ENDIAN__) && __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#define CHRONOS_BYTE_ORDER CHRONOS_BYTE_ORDER_LITTLE_ENDIAN
#elif defined(__BYTE_ORDER__) && defined(__ORDER_BIG_ENDIAN__) && __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
#define CHRONOS_BYTE_ORDER CHRONOS_BYTE_ORDER_BIG_ENDIAN
#elif defined(CHRONOS_WIN)
// Every architecture supported by Windows is little endian, and msvc does not define __BYTE_ORDER__ 
#define CHRONOS_BYTE_ORDER CHRONOS_BYTE_ORDER_LITTLE_ENDIAN
#else
#error "Cannot detect the byte order"
#endif // defined(__BYTE_ORDER__) && ... 

// Symbols visibility 
#if defined(CHRONOS_WIN)
#if defined(CHRONOS_MSVC)
#define CHRONOS_EXPORT __declspec(dllexport)
#define CHRONOS_IMPORT __declspec(dllimport)
#else
#define CHRONOS_EXPORT __attribute__((dllexport))
#define CHRONOS_IMPORT __attribute__((dllimport))
#endif // defined(CHRONOS_MSVC) 
#else
#define CHRONOS_EXPORT __attribute__((visibility("default")))
#define CHRONOS_IMPORT
#endif // defined(CHRONOS_WIN) 

#if defined(CHRONOS_BUILD_SHARED)
#define CHRONOS_API CHRONOS_EXPORT
#define CHRONOS_EXPIMP_TEMPLATE
#else
#define CHRONOS_API CHRONOS_IMPORT
#define CHRONOS_EXPIMP_TEMPLATE extern
#endif // defined(CHRONOS_BUILD_SHARED) 

// Inlining 
#if defined(CHRONOS_MSVC)
#define CHRONOS_FORCE_INLINE __forceinline
#define CHRONOS_NO_INLINE __declspec(noinline)
#else
#define CHRONOS_FORCE_INLINE inline __attribute__((always_inline))
#define CHRONOS_NO_INLINE __attribute__((noinline))
#endif // defined(CHRONOS_MSVC) 

// On Windows DllMain calls lib_entry/lib_exit (mingw and clang included, they would run twice otherwise) 
#if defined(CHRONOS_WIN)
#define CHRONOS_LIB_ENTRY
#define CHRONOS_LIB_EXIT
#else
#define CHRONOS_LIB_ENTRY __attribute__((constructor))
#define CHRONOS_LIB_EXIT __attribute__((destructor))
#endif // defined(CHRONOS_WIN) 

#define CHRONOS_CPP_ENTER extern "C" {
#define CHRONOS_CPP_END }

// Attributes and hints 
#define CHRONOS_NO_DISCARD [[nodiscard]]
#define CHRONOS_MAYBE_UNUSED [[maybe_unused]]

#if defined(CHRONOS_GCC) || defined(CHRONOS_CLANG)
#define CHRONOS_LIKELY(x) __builtin_expect((x) != 0, 1)
#define CHRONOS_UNLIKELY(x) __builtin_expect((x) != 0, 0)
#else
#define CHRONOS_LIKELY(x) (x)
#define CHRONOS_UNLIKELY(x) (x)
#endif // defined(CHRONOS_GCC) || defined(CHRONOS_CLANG) 

// __restrict is understood by msvc, gcc and clang, in C and C++ and whatever the standard 
#define CHRONOS_RESTRICT __restrict

#if defined(CHRONOS_MSVC)
#define CHRONOS_NO_VECTORIZATION __pragma(loop(no_vector))
#else
#define CHRONOS_NO_VECTORIZATION
#endif // defined(CHRONOS_MSVC) 

#if defined(CHRONOS_MSVC)
#define CHRONOS_PACKED_STRUCT(__struct__) __pragma(pack(push, 1)) __struct__ __pragma(pack(pop))
#else
#define CHRONOS_PACKED_STRUCT(__struct__) __struct__ __attribute__((__packed__))
#endif // defined(CHRONOS_MSVC) 

// gcc -pedantic rejects __PRETTY_FUNCTION__ in C, __func__ is standard since C99 
#if defined(CHRONOS_MSVC)
#define CHRONOS_FUNCTION __FUNCTION__
#else
#define CHRONOS_FUNCTION __PRETTY_FUNCTION__
#endif // defined(CHRONOS_MSVC) 

#if defined(CHRONOS_CLANG)
#define dump_struct(s) __builtin_dump_struct(s, printf)
#else
#define dump_struct(s)
#endif // defined(CHRONOS_CLANG) 

// Utilities 
#define CHRONOS_STATIC_FUNCTION static

#define CHRONOS_UNUSED(x) ((void)(x))

#define CONCAT_(prefix, suffix) prefix##suffix
#define CONCAT(prefix, suffix) CONCAT_(prefix, suffix)

#define CHRONOS_STRLIT_AND_SZ(s) (s), (sizeof((s)) - 1)

#define CHRONOS_STATIC_ASSERT(expr, message) static_assert(expr, message)

#if defined(DEBUG_BUILD)
#define CHRONOS_DEBUG 1
#define CHRONOS_ASSERT(expr, message)                                                                \
    do                                                                                           \
    {                                                                                            \
        if(!(expr))                                                                              \
        {                                                                                        \
            CHRONOS_LIBC(fprintf)(stderr,                                                            \
                              "Assertion failed in file %s at line %d: %s\n",                    \
                              __FILE__,                                                          \
                              __LINE__,                                                          \
                              message);                                                          \
            CHRONOS_LIBC(abort)();                                                                   \
        }                                                                                        \
    } while(0)
#else
#define CHRONOS_DEBUG 0
#define CHRONOS_ASSERT(expr, message) ((void)0)
#endif // defined(DEBUG_BUILD) 

// __PRETTY_FUNCTION__ is not a string literal, it cannot be concatenated 
#define CHRONOS_NOT_IMPLEMENTED                                                                      \
    do                                                                                           \
    {                                                                                            \
        CHRONOS_LIBC(fprintf)(stderr,                                                                \
                          "Called function %s that is not implemented (%s:%d)\n",               \
                          CHRONOS_FUNCTION,                                                          \
                          __FILE__,                                                              \
                          __LINE__);                                                             \
        CHRONOS_LIBC(exit)(1);                                                                       \
    } while(0)

#define CHRONOS_ATEXIT_REGISTER(func, do_exit)                                                       \
    do                                                                                           \
    {                                                                                            \
        if(CHRONOS_LIBC(atexit)(func) != 0)                                                          \
        {                                                                                        \
            CHRONOS_LIBC(fprintf)(stderr, "Cannot register function \"" #func "\" in atexit\n");     \
            if(do_exit)                                                                          \
                CHRONOS_LIBC(exit)(1);                                                               \
        }                                                                                        \
    } while(0)

// C++ utilities 
#define CHRONOS_NAMESPACE_BEGIN namespace chronos {
#define CHRONOS_NAMESPACE_END }

#define DETAIL_NAMESPACE_BEGIN namespace detail {
#define DETAIL_NAMESPACE_END }

#define CHRONOS_NON_COPYABLE(__class__)                                                              \
    __class__(const __class__&) = delete;                                                        \
    __class__& operator=(const __class__&) = delete

#define CHRONOS_NON_MOVABLE(__class__)                                                               \
    __class__(__class__&&) = delete;                                                             \
    __class__& operator=(__class__&&) = delete

#endif // !defined(__CHRONOS) 
