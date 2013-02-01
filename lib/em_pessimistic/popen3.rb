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
require "eventmachine"

# Original implementation at
# https://gist.github.com/535644/
#
module EMPessimistic
  class Popen3StderrHandler < EventMachine::Connection
    def initialize(connection)
      @connection = connection
    end

    def receive_data(data)
      @connection.receive_stderr(data)
    end
  end

  def self.popen3(*args)
    new_stderr = $stderr.dup
    rd, wr = IO::pipe
    $stderr.reopen(wr)
    connection = EM.popen(*args)
    $stderr.reopen(new_stderr)
    EM.attach(rd, Popen3StderrHandler, connection) do |c|
      wr.close
      new_stderr.close
    end
    connection
  end
end
