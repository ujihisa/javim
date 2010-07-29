module Javim
  module_function

  @cachefile = File.expand_path('~/.javim_cache')

  def global
    File.exist?(@cachefile) or global_cache()
    table = {}
    File.read(@cachefile).each_line do |line|
      key, value = line.chomp.split ': ', 2
      table[key] ||= []
      table[key] << value
    end
    table
  end

  def global!
    system 'rm', @cachefile
    global
  end

  def global_cache
    jardir = '/System/Library/Frameworks/JavaVM.framework/Classes'
    File.open(@cachefile, 'w') do |io|
      io.puts `jar tf #{jardir}/classes.jar`.each_line.
        map(&:chomp).
        select {|i| /\/[A-Z]\w+\.class$/ =~ i }.
        reject {|i| /\$/ =~ i }.
        map {|file| file.split('/').last.gsub(/\.class$/, '') + ': "' + file.gsub('/', '.').gsub(/\.class$/, '') + '"' }.
        sort
    end
  end
end

if __FILE__ == $0
  require 'pp'
  pp Javim.global.select {|_, j| j.size > 1 }
end
