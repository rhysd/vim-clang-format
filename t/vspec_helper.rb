def which cmd
  dir = ENV['PATH'].split(':').find {|p| File.executable? File.join(p, cmd)}
  File.join(dir, cmd) unless dir.nil?
end

def locate query
  case RbConfig::CONFIG['host_os']
  when /^darwin/
    `mdfind #{query}`
  when /^linux/
    `locate #{query}`
  else
    raise "unknown environment"
  end
end

class Vspec

  private

  def detect_from_rtp
    @@detect_from_rtp ||= `vim -u ~/.vimrc -e -s -c 'set rtp' -c q`
                          .match(/^\s+runtimepath=(.+)\n$/)[0]
                          .split(',')
                          .find{|p| p =~ /vim-vspec$/ }
  end

  def detect_from_locate
    @@detect_from_locate ||= locate('vim-vspec').split("\n").first
  end

  def detect_vspec_root
    return detect_from_rtp if File.executable? File.join(detect_from_rtp, "bin", "vspec")
    return detect_from_locate if File.executable? File.join(detect_from_locate, "bin", "vspec")
    "#{ENV['HOME']}/.vim/bundle/vim-vspec"
  end

  public

  def initialize( path: File.executable?("/usr/local/bin/vim") ? "/usr/local/bin" : "",
                  vspec_root: detect_vspec_root )
    @path = path
    @vspec_root = vspec_root
    @vspec = File.join vspec_root, "bin", "vspec"
    raise "vspec is not found" unless File.executable? @vspec
  end

  def run(file, autoloads: [])
    @result = `PATH=#{@path}:$PATH #{@vspec} #{@vspec_root} #{autoloads.join ' '} #{file}`
    @success = @result.scan(/^Error detected while processing function/).empty?
  end

  def count_failed
    @result.scan(/^not ok /).size if @success && @result
  end

  def all_passed?
    count_failed == 0 if @success && @result
  end

  def success?
    @success
  end

  attr_reader :result

end

