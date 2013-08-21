require './t/vspec_helper'

task :travis do
  v = Vspec.new(vspec_root: "./vim-vspec")
  v.run "t/vspec.vim"
  puts v.result
  exit 1 if ! v.success? || v.count_failed > 0
end
