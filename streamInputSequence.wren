import "./streamChunk" for StreamChunk

class StreamInputSequence is Sequence {

	construct new(stream){
		_stream = stream
	}

	iterate(inputChunk){
		if(_stream.open == null){
			Fiber.abort("Can not write to a Stream that has not been opened")
		}
		if(_stream.open == false){
			return false
		}

		if(inputChunk is StreamChunk){
			System.print(inputChunk.value)
			_stream.enqueueChunk(inputChunk)
		}

		return StreamChunk.new(this)
	}

	iteratorValue(inputChunk){
		return inputChunk
	}
}
