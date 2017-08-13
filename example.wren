import "scheduler" for Scheduler
import "timer" for Timer
import "random" for Random

import "./main" for Stream, StreamFlags

var rand = Random.new()
var printDebugInfo = Fn.new { |x| System.print("\t\t===%(x)===") }

var stream = Stream.new( StreamFlags.writeable | StreamFlags.readable )

var readFiber = Fiber.new {
   printDebugInfo.call("Start read fiber")
	for( readValue in stream ){
		System.print("read from Stream:  \"%(readValue)\",\t(%(stream.bytesBuffered) bytes remaining in stream)")
	}
   printDebugInfo.call("End read fiber")
}
readFiber.call()


printDebugInfo.call("Open Stream")
stream.open()
printDebugInfo.call("Start writing to Stream")
for(i in 0..3){
	var writeValue = "_%(rand.int())"

	System.print("writing to Stream: \"%(writeValue)\"")

	stream.writeInterface = writeValue

	printDebugInfo.call("sleeping")
	Timer.sleep(200)
}
printDebugInfo.call("Stop writing to Stream")
printDebugInfo.call("Close Stream")
stream.close()

System.print("DONE!")
