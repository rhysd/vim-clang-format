## Format your C++ code [![Build Status](https://travis-ci.org/rhysd/vim-operator-clang-format.png?branch=master)](https://travis-ci.org/rhysd/vim-operator-clang-format)

This plugin provides a vim operator mapping to format your C++ code with specific coding style.

### Screenshot

![Screenshot](http://gifzo.net/BIteGJ9Vasg.gif)

### Requirements

- clang-format command which is bundled in clang tools
- [vim-operator-user](https://github.com/kana/vim-operator-user)
- [vimproc.vim](https://github.com/Shougo/vimproc.vim)(recommended)

### Usage

Map `<Plug>(operator-clang-format)` to your favorite key bind.

### Customization

- `g:operator_clang_format_code_style`

`g:operator_clang_format_code_style` is a base style.
`llvm`, `google`, `chromium`, `mozilla` is supported.
The default value is `google`.

- `g:operator_clang_format_style_options`

Coding style options as dictionary.

An example is below:

```vim
let g:operator_clang_format_style_options = {
            \ "AccessModifierOffset" : -4,
            \ "AllowShortIfStatementsOnASingleLine" : "true",
            \ "AlwaysBreakTemplateDeclarations" : "true",
            \ "Standard" : "C++11",
            \ "BreakBeforeBraces" : "Stroustrup"}
```

For config information, execute `clang-format -dump-config` command.

- `g:operator_clang_format_command`

Name of `clang-format`. If the name of command is not `clang-format`
or you want to specify a command by absolute path, set this variable.
Default value is `clang-format`.

- `g:operator_clang_format_extra_args`

You can specify more extra options in `g:operator_clang_format_extra_args` as String or List of String.

### Example

```vim
let g:operator_clang_format_style_options = {
            \ "AccessModifierOffset" : -4,
            \ "AllowShortIfStatementsOnASingleLine" : "true",
            \ "AlwaysBreakTemplateDeclarations" : "true",
            \ "Standard" : "C++11"}
autocmd FileType cpp map <buffer><Leader>x <Plug>(operator-clang-format)
```

### For More Information

```
$ clang-format -help
```

```
$ clang-format -dump-config
```

clang-format's documentation and API documentation is useful in some cases.

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
