#!/usr/bin/env ruby
# encoding: utf-8

require './t/vspec_helper'

v = Vspec.new(vspec_root: "./vim-vspec")
v.run "t/clang_format_spec.vim"
puts v.result
exit 1 if ! v.success? || v.count_failed > 0
