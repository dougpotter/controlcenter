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


require 'ruote/exp/commanded'
require 'ruote/exp/iterator'


module Ruote::Exp

  #
  # Iterating on a list of values
  #
  #   pdef = Ruote.process_definition :name => 'test' do
  #     iterator :on_val => 'alice, bob, charly', :to_var => 'v' do
  #       participant '${v:v}'
  #     end
  #   end
  #
  # This expression expects at list an 'on' attribute, which can be :on,
  # :on_val, :on_value for a value (usually a comma separated list), :on_v,
  # :on_var, :on_variable for a list contained in the designated variable and
  # :on_f, :on_fld, :on_field for a list contained in the designated workitem
  # field.
  #
  # The 'on' attribute is used to instruct the expression on which list/array
  # it should iterate.
  #
  # The 'to' attribute takes two forms, :to_v, :to_var, :to_variable or
  # :to_f, :to_fld, :to_field.
  #
  # The 'to' attribute instructs the iterator into which variable or field
  # it should place the current value (the value being iterated over).
  #
  # If there is no 'to' specified, the current value is placed in the variable
  # named 'i'.
  #
  # The variables 'ii' contains the index (from 0 to ...) of the current value
  # (think Ruby's #each_with_index).
  #
  # The 'on' attribute can be replaced by a :time or a :branches attribute.
  #
  #   pdef = Ruote.process_definition :name => 'test' do
  #     iterator :times => '3'
  #       participant 'accounting'
  #     end
  #   end
  #
  # will be equivalent to
  #
  #   pdef = Ruote.process_definition :name => 'test' do
  #     sequence do
  #       participant 'accounting'
  #       participant 'accounting'
  #       participant 'accounting'
  #     end
  #   end
  #
  #
  # == break/rewind/continue/skip/jump
  #
  # The 'iterator' expression understands a certain the following commands :
  #
  # * break (_break) : exits the iteration
  # * rewind : places the iteration back at the first iterated value
  # * continue : same as 'rewind'
  # * skip : skips a certain number of steps (relative)
  # * jump : jump to certain step (absolute)
  #
  #   pdef = Ruote.process_definition :name => 'test' do
  #     iterator :times => '3'
  #       sequence do
  #         participant 'accounting', :review => '${v:i}'
  #         rewind :if => '${f:redo_everything} == true'
  #       end
  #     end
  #   end
  #
  #
  # == break/rewind/continue/skip/jump with :ref
  #
  # An iterator can be tagged (with the :tag attribute) and directly referenced
  # from a break/rewind/continue/skip/jump command.
  #
  # It's very useful when iterators (and cursors/loops) are nested within each
  # other or when one has to act on an iterator from outside of it.
  #
  #   concurrence do
  #
  #     iterator :on => 'alpha, bravo, charly', :tag => 'review' do
  #       participant '${v:i}'
  #     end
  #
  #     # meanwhile ...
  #
  #     sequence do
  #       participant 'main control program'
  #       _break :ref => 'review', :if => '${f:cancel_review} == yes'
  #     end
  #   end
  #
  # in this example, the participant 'main control program' may cancel the
  # review.
  #
  #   iterator :on => 'c1, c2, c3', :to_f => 'client', :tag => 'main' do
  #     cursor do
  #       participant :ref => '${f:client}'
  #       _break :ref => 'main', :if => '${f:cancel_everything}'
  #       participant :ref => 'salesclerk'
  #       participant :ref => 'salesclerk'
  #     end
  #   end
  #
  # in this weird process, if one customer says "cancel everything" (set the
  # workitem field "cancel_everything" to true), then the whole iterator
  # gets 'broken' out of.
  #
  class IteratorExpression < CommandedExpression

    include IteratorMixin

    names :iterator

    def apply

      return reply_to_parent(h.applied_workitem) if tree_children.size < 1

      h.list = determine_list
      h.to_v, h.to_f = determine_tos
      h.position = -1

      h.to_v = 'i' if h.to_v == nil && h.to_f == nil

      move_on
    end

    protected

    def move_on (workitem=h.applied_workitem)

      h.position += 1

      com, arg = get_command(workitem)

      return reply_to_parent(workitem) if com == 'break'

      case com
        when 'rewind', 'continue' then h.position = 0
        when 'skip' then h.position += arg
        when 'jump' then h.position = arg
      end

      h.position = h.list.length + h.position if h.position < 0

      val = h.list[h.position]

      return reply_to_parent(workitem) if val == nil

      (h.variables ||= {})['ii'] = h.position

      if h.to_v
        h.variables[h.to_v] = val
      else #if h.to_f
        workitem['fields'][h.to_f] = val
      end

      apply_child(0, workitem)
        # persist is done in there
    end
  end
end

