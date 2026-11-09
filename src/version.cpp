// SPDX-License-Identifier: BSD-3-Clause 
// Copyright (c) 2026 - Present Romain Augier 
// All rights reserved. 

#include "chronos/version.hpp"

CHRONOS_NAMESPACE_BEGIN

stdromano::StringD version()
{
    return stdromano::StringD::make_fmt("chronos {} ({})", CHRONOS_VERSION_STR, CHRONOS_PLATFORM_STR);
}

CHRONOS_NAMESPACE_END
