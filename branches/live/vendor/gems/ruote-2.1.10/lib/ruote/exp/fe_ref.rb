#--
# Copyright (c) 2005-2010, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


module Ruote::Exp

  #
  # Sometimes you don't know at 'design time', if you want to trigger a
  # participant or subprocess.
  #
  #   Ruote.process_definition do
  #     sequence do
  #       participant 'alice'
  #       ref '${solver}'
  #       participant 'charlie'
  #     end
  #   end
  #
  # In this process, solver's name could be a participant name or a subprocess
  # name.
  #
  # Subprocesses have the priority over participants.
  #
  # Note : this expression is used by the worker when substituting unknown
  # expression names with participant or subprocess refs.
  #
  class RefExpression < FlowExpression

    names :ref

    def apply

      key = (attribute(:ref) || attribute_text).to_s

      if name != 'ref'
        key = name
        tree[1]['ref'] = key
      end

      key2, value = iterative_var_lookup(key)

      tree[1]['ref'] = key2 if key2
      tree[1]['original_ref'] = key if key2 != key

      unless value
        #
        # seems like it's participant

        @h['participant'] =
          @context.plist.lookup_info(tree[1]['ref'], h.applied_workitem)

        value = key2 if ( ! @h['participant']) && (key2 != key)
      end

      if value.is_a?(Array) && value.size == 2 && value.last.is_a?(Hash)
        #
        # participant 'defined' in var

        @h['participant'] = value
      end

      unless value || @h['participant']
        #
        # unknown participant or subprocess

        @h['state'] = 'failed'
        persist_or_raise

        raise("unknown participant or subprocess '#{tree[1]['ref']}'")
      end

      new_exp = if @h['participant']

        @h['participant'] = nil if @h['participant'].respond_to?(:consume)
          # instantiated participant

        tree[0] = 'participant'
        @h['name'] = 'participant'
        Ruote::Exp::ParticipantExpression.new(@context, @h)
      else

        tree[0] = 'subprocess'
        @h['name'] = 'subprocess'
        Ruote::Exp::SubprocessExpression.new(@context, @h)
      end

      #new_exp.initial_persist
        # not necessary

      new_exp.apply
    end
  end
end

