#include <iostream>

#define TEST_CPP_FOR_OPERATOR_CLANG_FORMAT_LONG_MACRO " CPP for vim-operator-clang-complete"

void f(){ std::cout << "hello\n"; }

int main()
{
    int * hoge = {1,3,5,7};

    for(int i=0;i<4;++i){
        if(i%2==0) std::cout << hoge[i] << std::endl;
    }

    std::cout << "this is very very long one-line string. so this line go over 80 column .\n";

    std::cout << "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:";
    return 0;
}
