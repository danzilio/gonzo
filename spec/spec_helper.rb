$LOAD_PATH.unshift File.join(File.dirname(__FILE__), *%w(.. lib))

def fixture_path
  File.expand_path(File.join(__FILE__, '..', '..', 'spec', 'fixtures'))
end

RSpec.configure do |c|
  c.formatter = 'documentation'
  c.color = true
end
