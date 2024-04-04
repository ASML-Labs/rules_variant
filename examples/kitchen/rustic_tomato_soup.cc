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

#include "basil.h"
#include "salt.h"
#include "tomato.h"
#include <iostream>

int main() {
    std::cout << "Dish: Rustic Tomato Soup" << std::endl;
    print_basil_variant(); // Implement according to the variant used
    print_salt();
    print_tomato_variant(); // Implement according to the variant used
    return 0;
}

