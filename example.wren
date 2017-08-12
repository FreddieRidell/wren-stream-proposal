import "scheduler" for Scheduler
import "timer" for Timer
import "random" for Random

import "./main" for Stream, StreamFlags

var rand = Random.new()

var stream = Stream.new( StreamFlags.writeable | StreamFlags.readable )

stream.readFiber = Fiber.new {
	for( readValue in stream ){
		System.print("read from Stream: \"%(readValue)\", (%(stream.bytesBuffered) bytes remaining in stream)")
	}

	System.print("read fiber says: 'fiber has been closed'")
}






stream.open()
System.print("write fiber says: 'fiber will now be opened'")

for(i in 0..5){
	var writeValue = "%(rand.int())"

	System.print("writing to Stream: \"%(writeValue)\"")

	stream.writeInterface = writeValue

	System.print("\n===sleeping===\n")
	Timer.sleep(200)
}

System.print("write fiber says: 'fiber will now be closed'")
stream.close()

System.print("DONE!")
