require 'spec_helper'
require 'reek/core/code_parser'

include Reek::Core

describe CodeParser, 'with no method definitions' do
  it 'reports no problems for empty source code' do
    expect('').not_to reek
  end
  it 'reports no problems for empty class' do
    expect('# clean class for testing purposes
class Fred; end').not_to reek
  end
end

describe CodeParser, 'with a global method definition' do
  it 'reports no problems for simple method' do
    src = 'def Outermost::fred() true; end'
    expect(src).not_to reek
  end
end

describe CodeParser, 'when a yield is the receiver' do
  it 'reports no problems' do
    src = <<EOS
def values(*args)
  @to_sql += case
    when block_given? then yield.to_sql
    else args.to_sql
  end
  self
end
EOS
    expect(src).not_to reek
  end
end
