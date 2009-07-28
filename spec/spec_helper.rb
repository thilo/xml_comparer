require 'rubygems'
require 'spec'
require File.dirname(__FILE__) + '/../xml_comparer'


# borrowed from zentest assertions...
def capture_io
  require 'stringio'
  orig_stdout = $stdout.dup
  captured_stdout = StringIO.new
  $stdout = captured_stdout
  yield
  captured_stdout.rewind
  return captured_stdout.string
  ensure
  $stdout = orig_stdout
end