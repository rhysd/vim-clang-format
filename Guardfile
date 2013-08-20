# encoding: utf-8

guard :shell do
  watch %r{^(.+\.vim)$} do
    `PATH=/usr/local/bin:$PATH $HOME/.vim/bundle/vim-vspec/bin/vspec $HOME/.vim/bundle/vim-vspec t/vspec.vim`
  end
end
