import "scheduler" for Scheduler
import "timer" for Timer
import "random" for Random

import "./main" for Stream

var rand = Random.new()

//Create a read stream, this can have data drained from it 
//using the itterator protocol, which creates a sequence of
//chunks that can be read.
//
//The sequence must be accessed inside a fiber, which will yield
//every time the Stream becomes empty
//
//The sequence ends when the Stream is closed
var readStream = Stream.readable()
var readFiber = Fiber.new {
	for( chunk in readStream.output ){
		System.print("Read from Stream: \"%(chunk.value)\"")
	}
}
readFiber.call()

//Create a transform stream, which can shape the data moving 
//through it.
//
//A transform Stream can not be read or written to outside of its
//transform callable
//
//The transform callable currently maps chunk.value to chunk.value;
//we could possibly change this to map chunk to chunk if that's better
var transformStream = Stream.transform { |value|
	var newValue = "+" + value + "+"
	System.print("Transform \"%(value)\" => \"%(newValue)\"")
	return newValue
}

//Create a write stream, which can be written to from userland
//
//This also produces a Sequence, which vends chunks that can be
//written to, at each itteration of the sequence, the data written
//to the chunk is sent to the next stage of the stream pipeline
var writeStream = Stream.writeable()

//Streams can be piped together.
//
//`pipe` returns its input, so they can be chained together like this:
//writeStream -> transformStream -> readStream
writeStream.pipe(transformStream).pipe(readStream)

//Streams must be opened before they can be written to.
//
//Opening a stream will also open all streams deeper down in 
//a pipeline
writeStream.open()

var i = 0
for(chunk in writeStream.input){
	i = i + 1
	if(i > 3){
		//closing the stream will end its sequence, and also
		//close all streams deeper down in a pipeline
		writeStream.close()
		break
	}

	chunk.value = "(%(rand.int()))"

	System.print("\nWrite to Stream:   \"%(chunk.value)\"")
}

System.print("DONE!")
