# encoding: utf-8

def which cmd
  dir = ENV['PATH'].split(':').find {|p| File.executable? File.join(p, cmd)}
  File.join(dir, cmd) unless dir.nil?
end

def notify failed
  msg = "'#{failed} test#{failed>1 ? 's' : ''} failed.\n#{Time.now.to_s}'"
  case
  when which('terminal-notifier')
    `terminal-notifier -message #{msg}`
  when which('notify-send')
    `notify-send #{msg}`
  when which('tmux')
    `tmux display-message #{msg}` if `tmux list-clients 1>/dev/null 2>&1` && $?.success?
  end
end


guard :shell do
  watch /^(.+\.vim)$/ do |m|
    result = `PATH=/usr/local/bin:$PATH $HOME/.vim/bundle/vim-vspec/bin/vspec $HOME/.vim/bundle/vim-vspec t/vspec.vim`
    failed = result.scan(/^not ok /).size
    notify(failed) unless failed==0
    result
  end
end
