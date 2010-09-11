
#
# testing ruote
#
# Tue Sep 15 09:04:36 JST 2009
#

require File.join(File.dirname(__FILE__), 'base')

require 'ruote/part/smtp_participant'


class NftSmtpParticipantTest < Test::Unit::TestCase
  include FunctionalBase

  unless Ruote::JAVA

    require 'mailtrap' # sudo gem install mailtrap

    class Trap < ::Mailtrap
      def puts (s)
        # silent night...
      end
    end
  end

#  def test_smtp
#
#    return if Ruote::JAVA
#
#    pdef = Ruote.process_definition :name => 'test' do
#      sequence do
#        set 'f:item' => 'cat food'
#        alpha
#      end
#    end
#
#    trapfile = Ruote::WIN ? 'ruote_mailtrap.txt' : '/tmp/ruote_mailtrap.txt'
#    FileUtils.rm_f(trapfile)
#
#    t = Thread.new do
#      Trap.new('127.0.0.1', 2525, true, trapfile)
#    end
#    sleep 0.040
#      # give it some time to start listening
#
#    @engine.register_participant(
#      :alpha,
#      Ruote::SmtpParticipant.new(
#        :server => '127.0.0.1',
#        :port => 2525,
#        :to => 'toto@cloudwhatever.ch',
#        :from => 'john@outoftheblue.ch',
#        :notification => true,
#        :template => %{
#  Hello, do you want ${f:item} ?
#        }))
#
#    #noisy
#
#    wfid = @engine.launch(pdef)
#
#    #sleep 0.450
#    wait_for(wfid)
#
#    assert_match(/cat food/, File.read(trapfile))
#    assert_nil @engine.process(wfid)
#
#    t.kill
#  end

  def test_smtp_non_instance_participant

    return if Ruote::JAVA

    pdef = Ruote.process_definition :name => 'test' do
      sequence do
        set 'f:item' => 'cat food'
        alpha
      end
    end

    trapfile = Ruote::WIN ? 'ruote_mailtrap.txt' : '/tmp/ruote_mailtrap.txt'
    FileUtils.rm_f(trapfile)

    t = Thread.new do
      Trap.new('127.0.0.1', 2525, true, trapfile)
    end
    sleep 0.040
      # give it some time to start listening

    @engine.register_participant(
      :alpha,
      Ruote::SmtpParticipant,
      :server => '127.0.0.1',
      :port => 2525,
      :to => 'toto@cloudwhatever.ch',
      :from => 'john@outoftheblue.ch',
      :notification => true,
      :template => %{
  Hello, do you want ${f:item} ?
      })

    #noisy

    wfid = @engine.launch(pdef)

    #sleep 0.450
    wait_for(wfid)

    assert_match(/want cat food/, File.read(trapfile))
    assert_nil @engine.process(wfid)

    t.kill
  end
end

