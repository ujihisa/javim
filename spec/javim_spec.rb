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

describe 'Javim.global' do
  it 'is a hash of classname and packagename of java builtin libraries like Vector' do
    table = Javim.global
    table.keys.should be_include 'Vector'
    table.values.should be_include ['java.util.Vector']
  end
end
