require 'strscan'

module Javim
  module_function

  def local(jarfile)
    return @local if @local
    `jar tf #{jarfile}`.each_line.
      map(&:chomp).
      select {|i| /\/[A-Z]\w+\.class$/ =~ i }.
      reject {|i| /\$/ =~ i }.
      map {|file| [file.split('/').last.gsub(/\.class$/, ''), file.gsub('/', '.').gsub(/\.class$/, '')]}.
      reject {|c, p| /^java\.lang\.|\.internal\./ =~ p }.
      inject({}) {|memo, (c, p)| memo[c] ||= []; memo[c] << p; memo }
  end

  @cachefile = File.expand_path('~/.javim_cache')

  def global
    return @global if @global
    File.exist?(@cachefile) or global_cache()
    table = {}
    File.read(@cachefile).each_line do |line|
      key, value = line.chomp.split ': ', 2
      table[key] ||= []
      table[key] << value[/"(.*?)"/, 1]
    end
    @global = table
  end

  def global!
    system 'rm', @cachefile if File.exist? @cachefile
    global
  end

  def keywords_of(a_java_file)
    s = StringScanner.new File.read(File.expand_path(a_java_file))
    keywords = []
    until s.eos?
      case
      # ignore string
      when s.scan(/"([^\\"]|\\.)*"/m)
      when s.scan(/'([^\\']|\\.)*'/m)
      # ignore comment
      when s.scan(%r|//.*|)
      when s.scan(%r|/\*.*\*/|m)
      # ignore identifiers except classes
      when s.scan(/[a-z_]\w*/)
      # keyword
      when s.scan(/[A-Z]\w*/)
        keywords << s[0]
      when s.scan(/./m)
      end
    end
    keywords.uniq
  end

  private
  module_function

  def global_cache
    jardir = '/System/Library/Frameworks/JavaVM.framework/Classes'
    File.open(@cachefile, 'w') do |io|
      io.puts `jar tf #{jardir}/classes.jar`.each_line.
        map(&:chomp).
        select {|i| /\/[A-Z]\w+\.class$/ =~ i }.
        reject {|i| /\$/ =~ i }.
        map {|file| [file.split('/').last.gsub(/\.class$/, ''), file.gsub('/', '.').gsub(/\.class$/, '')]}.
        reject {|c, p| /^java\.lang\.|\.internal\./ =~ p }.
        map {|c, p| c + ': "' + p + '"' }.
        sort
    end
  end
end
