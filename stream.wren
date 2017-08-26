import "./streamChunk" for StreamChunk, WriteableStreamChunk, ReadableStreamChunk
import "./streamInputSequence" for StreamInputSequence
import "./streamOutputSequence" for StreamOutputSequence

class Stream {
	open { _open }

	input {
		if(!_writeable){
			Fiber.abort("Can not write to non-writeable stream")
		}
		return StreamInputSequence.new(this)
	}
	output { 
		if(!_readable){
			Fiber.abort("Can not read to non-readable stream")
		}
		if(_outputSequence){
			Fiber.abort("Can only create one StreamOutputSequence for a Stream")
		}
		_outputSequence= StreamOutputSequence.new(this)
		return _outputSequence
	}

	construct readable() {
		_readable = true
		_writeable = false
	}

	construct writeable() {
		_readable = false
		_writeable = true
	}

	construct transform(transform) {
		_readable = false 
		_writeable = false
		_transform = transform
	}

	open(){
		_open = true

		if(_pipeToStream){
			_pipeToStream.open()
		}
	}

	close(){
		_open = false
		
		if(_pipeToStream){
			_pipeToStream.close()
		}
	}

	enqueueChunk(chunk){
		if(_transform){
			var transformedChunk = ReadableStreamChunk.new(
				_transform.call(chunk.value)
			)

			dequeueChunk(transformedChunk)
		} else {
			dequeueChunk(chunk)
		}
	}

	dequeueChunk(chunk){
		if(_pipeToStream){
			_pipeToStream.enqueueChunk(chunk)
		} else {
			_outputSequence.dequeueChunk(chunk)
		}
	}

	pipe(stream){
		_pipeToStream = stream

		return stream
	}
}
