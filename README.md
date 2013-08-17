## Format your C++ code

This plugin provides a vim operator mapping to format your C++ code with specific coding style.

### Screenshot

![Screenshot](http://gifzo.net/BTZFDliMJSa.gif)

### Requirements

- clang-format command in your $PATH.
- [vim-operator-user](https://github.com/kana/vim-operator-user)

### Usage

Map `<Plug>(operator-clang-format)` to your favorite key bind.

### Customize

- `g:operator_clang_format_code_style`

`g:operator_clang_format_code_style` is a base style.
`llvm`, `google`, `chromium`, `mozilla` is supported.

- `g:operator_clang_format_clang_args`

You can specify more extra options in `g:operator_clang_format_clang_args` as String or List of String.

### For More Information

```
clang-format -help
clang-format -dump-config
```

### License

    The MIT License (MIT)

    Copyright (c) <year> <copyright holders>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
