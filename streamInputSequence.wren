import "./streamChunk" for StreamChunk, WriteableStreamChunk

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
			_stream.enqueueChunk(inputChunk)
		}

		return WriteableStreamChunk.new()
	}

	iteratorValue(inputChunk){
		return inputChunk
	}
}
