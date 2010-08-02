unless respond_to? :require_relative
  def require_relative(o)
    require File.dirname(__FILE__) + "/#{o}"
  end
end
require_relative '../lib/javim'

describe 'Javim.local("fixture.jar")' do
  before do
    @jarfile = File.dirname(__FILE__) + '/fixture.jar'
  end

  it 'is a hash of classname and packagename' do
    table = Javim.local(@jarfile)
    table.keys.should be_include 'Hello'
    table.values.should be_include ['src.Hello']
  end

  it "doesn't contain system packages like Vector" do
    table = Javim.local(@jarfile)
    table.keys.should_not be_include 'Vector'
  end
end

describe 'Javim.local(".")' do
  it 'is same to the case of passing fixture.jar' do
    table = Javim.local File.dirname(__FILE__) + '/'
    table.keys.should be_include 'Hello'
    table.values.should be_include ['src.Hello']
  end
end

describe 'Javim.global' do
  it 'is a hash of classname and packagename of java builtin libraries like Vector' do
    table = Javim.global
    table.keys.should be_include 'Vector'
    table.values.should be_include ['java.util.Vector']
  end
end

describe 'javim command' do
  before do
    @javim_cmd = File.dirname(__FILE__) + '/../bin/javim'
    @java_file = File.dirname(__FILE__) + '/src/Hello.java'
  end

  it 'shows the list of import statements the java file needs' do
    `#{@javim_cmd} #{@java_file}`.chomp.should ==
      'import java.util.Vector;'
  end

  it 'also shows import statements for packages given as the 2nd argument' do
    jar_file = File.dirname(__FILE__) + '/fixture.jar'
    `#{@javim_cmd} #{@java_file} #{jar_file}`.should ==
      "import java.util.Vector;\nimport src.Hello;\n"
  end

  it 'also accepts dirname instead of jar filename' do
    currentdir = File.dirname(__FILE__)
    `#{@javim_cmd} #{@java_file} #{currentdir}`.should ==
      "import java.util.Vector;\nimport src.Hello;\n"
  end
end
