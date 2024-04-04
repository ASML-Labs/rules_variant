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

#include "seasoned_tomato_sauce.h"
#include "tomato.h"
#include "basil.h"
#include "olive_oil.h"
#include "salt.h"


#include <iostream>

#define STRINGIZE(x) #x
#define STRINGIZE_VALUE_OF(x) STRINGIZE(x)


void print_seasoned_tomato_sauce_variant() {
    std::cout << "Ingredient: " << STRINGIZE_VALUE_OF(SAUCE_BLEND) << " Seasoned Tomato Sauce " << std::endl;
    print_tomato_variant();
    print_basil_variant();
    print_olive_oil();
    print_salt();
#ifdef EXTRA_SALTY 
    print_extra_salty_salt();
#endif
}

