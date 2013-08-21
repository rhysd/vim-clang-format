def which cmd
  dir = ENV['PATH'].split(':').find {|p| File.executable? File.join(p, cmd)}
  File.join(dir, cmd) unless dir.nil?
end

class Vspec

  def detect_vspec_root
    if which 'locate'
      `locate vim-vspec`.split("\n").first
    else
      File.join(ENV['HOME'], ".vim/bundle/vim-vspec")
    end
  end

  private :detect_vspec_root

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
    @result.scan(/^not ok /).size if @success
  end

  def all_passed?
    count_failed == 0 if @success
  end

  def success?
    @success
  end

  attr_reader :result

end
