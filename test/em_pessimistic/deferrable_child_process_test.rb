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
require "test_helper"
require "em_pessimistic/deferrable_child_process"

describe EMPessimistic::DeferrableChildProcess do
  include EM::MiniTest::Spec

  it "passes stdout data and status to callback on success" do
    process = EMPessimistic::DeferrableChildProcess.open("ls -l")
    process.callback do |stdout, stderr, status|
      assert_match /em_pessimistic\.gemspec/, stdout
      assert_equal 0, status.exitstatus
      done!
    end
    wait!
  end

  it "passes stderr data and status to errback on error" do
    cmd = "git ls-tree master:Gemfile"
    process = EMPessimistic::DeferrableChildProcess.open(cmd)
    process.errback do |stderr, stdout, status|
      assert_equal "fatal: not a tree object", stderr
      assert_equal 128, status.exitstatus
      done!
    end
    wait!
  end
end
