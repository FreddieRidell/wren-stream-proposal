import "scheduler" for Scheduler
import "timer" for Timer
import "random" for Random

import "./main" for Stream, StreamFlags

var rand = Random.new()
var printDebugInfo = Fn.new { |x| System.print("\t\t===%(x)===") }

var stream = Stream.new( StreamFlags.writeable | StreamFlags.readable )

var readFiber = Fiber.new {
   printDebugInfo.call("Start read fiber")

	for( chunk in stream.output ){
		System.print("read from Stream:  \"%(chunk.value)\"")
	}

   printDebugInfo.call("End read fiber")
}
readFiber.call()

printDebugInfo.call("Open Stream")
stream.open()
printDebugInfo.call("Start writing to Stream")

var i = 0
for(chunk in stream.input){

	chunk.value = "(%(rand.int()))"

	i = i + 1
	if(i > 3){
		printDebugInfo.call("Stop writing to stream")
		printDebugInfo.call("Close Stream")
		stream.close()
	}
}


System.print("DONE!")
