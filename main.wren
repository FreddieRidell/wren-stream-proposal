import "random" for Random

import "./stream" for Stream, StreamFlags

var stream = Stream.new( StreamFlags.writeable | StreamFlags.readable )
var readingInterface = stream.readingInterface
var writingInterface = stream.writingInterface

var rand = Random.new()
stream.addWriteListener {
	var numToRead = rand.int(3, 6)
	System.print("read: {%(readingInterface.call(numToRead))}")
}

stream.open()

for (i in 1..8 ) {
	System.print(i)
	System.print("write: {abcdefgh}")
	System.print("unbuffered: {%(writingInterface.call("abcdefgh"))}")
	/*System.print("bytesBuffered: {%(stream.hasBuffered)}")*/
	System.print()
}

System.print("finaly:")
	while(stream.hasBuffered){
		var numToRead = rand.int(2, 7)
		System.print("read: {%(readingInterface.call(numToRead))}")
	}

stream.close()
