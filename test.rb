require "eventmachine"
require "em_pessimistic"

def done(label)
  return Proc.new do |data, status|
    border = "=" * (label.length + 1)
    puts "#{label}:\n#{border}\n#{data}"
    EM.stop
  end
end

puts "This example should fail"

EM.run do
  EM.next_tick do
    $stderr.puts "stderr before"

    git = EMPessimistic::DeferrableChildProcess.open("git ls-tree master:")
    git.callback(&done("All's well"))
    git.errback(&done("All's hell"))

    $stderr.puts "stderr after"
  end
end

puts "This example should succeed"

EM.run do
  EM.next_tick do
    $stderr.puts "stderr before"

    git = EMPessimistic::DeferrableChildProcess.open("ls -l")
    git.callback(&done("All's well"))
    git.errback(&done("All's hell"))

    $stderr.puts "stderr after"
  end
end
