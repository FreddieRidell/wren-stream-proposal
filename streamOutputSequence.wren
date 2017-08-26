import "./streamChunk" for StreamChunk

class StreamOutputSequence is Sequence {

	construct new(stream){
		_stream = stream
	}

	enqueueChunk(chunk){
		_recievedChunk = chunk
		_outputFiber.call()
	}

	iterate(outputChunk){
		if(!_recievedChunk){
			//first call
			_outputFiber = Fiber.current
			Fiber.yield()
			return iterate(outputChunk)
		}

		if(_recievedChunk is StreamChunk){
			var drain = _recievedChunk
			_recievedChunk = null
			return drain
		}

		System.print(outputChunk)
	}

	iteratorValue(outputChunk){
		return outputChunk
	}
}
