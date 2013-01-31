# EMPessimistic (GREAT THANKS TO AUTHOR: [Christian Johansen](https://github.com/cjohansen))

*Pessimistic child processes for EventMachine.*

THIS IMPLEMENTATION SOLVES "cjohansen/em_pessimistic" PROBLEM WITH "TOO MUCH FILE HANDLES OPENED" SYSTEM ERROR
IN LONG RUNNING APPLICATIONS.
IMPROVED:
   - "new_stderr" and "wr" closed after descriptor is attached to process connnection.
   - "close_connection" invokes strictly after data received.
   - "@io.close" invokes strictly after unbind.

EventMachine provides both `EM.popen` and `EM::DeferrableChildProcess`, but none
of them are particularly useful in the case of your process exiting with an
error.

`EMPessimistic` provides `popen3` and a `DeferrableChildProcess` that caters for
failing child processes.

## API Docs

### `EMPessimistic.popen3(cmd, handler=nil, *args)`

Works like
[`EM::popen`](http://eventmachine.rubyforge.org/EventMachine.html#M000491).
Additionally, it sends data from the process' stderr to the handler's
`receive_stderr` method.

    require "em_pessimistic"
    require "eventmachine"

    class LsHandler < EventMachine::Connection
      def initialize(*args)
        puts "Initializing command"
      end

      def receive_data(data)
        puts "Received stdout: #{data}"
      end

      def receive_stderr(data)
        puts "Received stderr: #{data}"
      end

      def unbind
        puts "All done"
        EM.stop
      end
    end

    EM.run do
      EMPessimistic.popen3("ls -l", LsHandler)
      EMPessimistic.popen3("ls -l /oh/noes", LsHandler)
    end

### `EMPessimistic.::DeferrableChildProcess`

Works mostly like
[`EM::DeferrableChildProcess`](http://eventmachine.rubyforge.org/EventMachine/DeferrableChildProcess.html).

    # I suppose that EM has already been run.

    child = EMPessimistic::DeferrableChildProcess.open(command)

    child.callback do |data, err, status|
      # Your code here...
    end

    child.errback do |data, err, status|
      # Your code here...
    end


## Installing

`em_pessimistic` ships as a gem:

    $ gem install em_pessimistic

Or in your Gemfile:

    gem "em_pessimistic", "~> 0.1"

## Contributing

Contributions are welcome. To get started:

    $ git clone git://gitorious.org/gitorious/em_pessimistic.git
    $ cd em_pessimistic
    $ bundle install
    $ rake

When you have fixed a bug/added a feature/done your thing, create a
[clone on Gitorious](http://gitorious.org/gitorious/em_pessimistic) or a
[fork on GitHub](http://github.com/cjohansen/em_pessimistic) and send a
merge request/pull request, whichever you prefer.

Please add tests when adding/altering code, and always make sure all the tests
pass before submitting your contribution.

## License

### The MIT License (MIT)

**Copyright (C) 2012 Gitorious AS**

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
