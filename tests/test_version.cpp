// SPDX-License-Identifier: BSD-3-Clause 
// Copyright (c) 2026 - Present Romain Augier 
// All rights reserved. 

#include "chronos/version.hpp"

#include "stdromano/test.hpp"

STDROMANO_TEST_CASE(version_string)
{
    const stdromano::StringD version = chronos::version();

    STDROMANO_CHECK(version.startswith("chronos "));
    STDROMANO_CHECK_NE(version.find(CHRONOS_VERSION_STR), -1);
    STDROMANO_CHECK_NE(version.find(CHRONOS_PLATFORM_STR), -1);
}

STDROMANO_TEST_MAIN()
