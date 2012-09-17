# encoding: utf-8
# --
# The MIT License (MIT)
#
# Copyright (C) 2012 Gitorious AS
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++
require "em_pessimistic/popen3"
require "eventmachine"

module EMPessimistic
  class DeferrableChildProcess < EventMachine::Connection
    include EventMachine::Deferrable

    def initialize
      super
      @stdout = []
      @stderr = []
    end

    def self.open(cmd)
      EMPessimistic.popen3(cmd, DeferrableChildProcess)
    end

    def receive_data(data)
      @stdout << data
    end

    def receive_stderr(data)
      @stderr << data
    end

    def unbind
      status = get_status
      if status.exitstatus != 0
        fail(@stderr.join.strip, status)
      else
        succeed(@stdout.join.strip, status)
      end
    end
  end
end
