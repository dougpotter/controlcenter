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


module Ruote

  #
  # Encapsulating all the information about an error in a process instance.
  #
  class ProcessError

    def initialize (h)
      @h = h
    end

    def message
      @h['message']
    end

    def trace
      @h['trace']
    end

    def msg
      @h['msg']
    end

    def fei
      Ruote::FlowExpressionId.new(msg['fei'])
    end

    def tree
      @h['msg']['tree']
    end

    def at
      @h['msg']['put_at']
    end

    # A shortcut for modifying the tree of an expression when it has had
    # an error upon being applied.
    #
    def tree= (t)
      @h['msg']['tree'] = t
    end

    def to_h
      @h
    end

    # 'apply', 'reply', 'receive', ... Indicates in which "direction" the
    # error occured.
    #
    def action
      @h['msg']['action']
    end

    # Exposes the workitem fields directly.
    #
    def fields
      @h['msg']['workitem']['fields']
    end

    protected

    def to_dot (opts)

      i = fei.to_storage_id
      label = "error : #{message.gsub(/"/, "'")}"

      [
        "\"err_#{i}\" [ label = \"#{label}\" ];",
        "\"err_#{i}\" -> \"#{i}\" [ style = \"dotted\" ];"
      ]
    end
  end
end

