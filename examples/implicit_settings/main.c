// Copyright (c) 2026, ASML Netherlands B.V.
// All rights reserved
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <stdio.h>

#define STRINGIZE(x) #x
#define STRINGIZE_VALUE_OF(x) STRINGIZE(x)


int main(int argc, char *argv[])
{
    printf("\n--------------\n");
    printf("well_known:     %s\n", STRINGIZE_VALUE_OF(WELL_KNOWN));
    printf("    secret:     %s", STRINGIZE_VALUE_OF(SECRET));
    printf("\n--------------\n");
    return 0;
}
