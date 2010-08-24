
#
# testing ruote
#
# Sun Aug 16 20:46:13 JST 2009
#

require File.join(File.dirname(__FILE__), 'base')


class EftNoOpTest < Test::Unit::TestCase
  include FunctionalBase

  def test_no_operation

    pdef = Ruote.process_definition :name => 'test' do
      sequence do
        noop
        echo 'done.'
      end
    end

    #noisy

    assert_trace('done.', pdef)
  end
end

