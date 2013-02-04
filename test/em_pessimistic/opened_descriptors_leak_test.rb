# encoding: utf-8
# --
# The MIT License (MIT)
#
# Copyright (C) 2013 Andrey Chergik
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
require "test_helper"
require 'fosl/parser'
require "em_pessimistic/deferrable_child_process"


describe EMPessimistic::DeferrableChildProcess do
  include EM::MiniTest::Spec

  def setup
    @parse = FOSL::Parser.new
    @pid = Process.pid
  end

  def _lsof
    Hash[ @parse.lsof("+p #{@pid}")[@pid].files.group_by { |f| f[:type] }.select { |k,v| /^(?:unix|PIPE|FIFO)$/.match(k) }]
  end

  def _pipes?(data)
    data['PIPE'] || data['FIFO']
  end

  def _unix?(data)
    data['unix']
  end

  def timeout_interval
   5
  end

  it "has no dubious opened pipes and unix domain sockets after all child processes exited" do

    finished = 0
    default_data = _lsof
    default_pipes = _pipes?(default_data)
    default_unix = _unix?(default_data)

    # Increase this amount to your ("system opened file descriptors limit" / 3) and you will meet "Errno::EMFILE: Too many open files" exception.
    amount = 1

    EM.add_periodic_timer(1) do

      data = _lsof
      pipes = _pipes?(data)
      unix = _unix?(data)
      if finished == amount
        assert pipes, 'there are several PIPEs owned by this process'

        # One Pipe is for "lsof" process. Two others for EM loop.
        assert_equal default_pipes.length, pipes.length
        if default_unix
          assert_equal default_unix.length, unix.length
        else
          assert !unix, 'all unix domain sockets for this process are closed'
        end
        done!
      else
        ap data
      end

    end

    amount.times do |i|
      process = EMPessimistic::DeferrableChildProcess.open("ruby -v")

      process.callback do |stdout, stderr, status|
        finished += 1
      end

      process.errback do |stderr, stdout, status|
        finished += 1
      end
    end

    wait!

  end
end

