class StreamFlags {
	static readable         { 0x01 } //the Stream is readable from wren-land
	static writeable        { 0x02 } //the Stream is writeable from wren-land
	static readPartialChunk { 0x04 } //the Stream can output chunks that are smaller than the chunkSize
}

class Stream {
	construct new(flags){
		_buffer = "" //initial buffer contents
		_chunkSize = 4 //the number of bytes read from the buffer at a time
		_flags = flags //the config flags for the Stream, see above
	}

	bytesBuffered { _buffer.bytes.count }
	chunkSize { _chunkSize }
	hasBuffered { this.bytesBuffered != 0 }
	open { _open }

	readable { _flags & StreamFlags.readable != 0 }
	writeable { _flags & StreamFlags.writeable != 0 }
	readPartialChunk { _flags & StreamFlags.readPartialChunk != 0 }

	writeInterface=(input){
		//add content to the buffer
		_buffer = _buffer + input
		//and call our read fiber to read it out
		if(_readFiber) _readFiber.call()
	}
	
	chunkSize=(n) {
		//set the chunk size
		if(!this.writeable){
			Fiber.abort("Can only set the chunk size of a writable Stream")
		}

		if(!open){
			Fiber.abort("Can only write to an open Stream")
		}

		_chunkSize = n
	}
	
	open() {
		_open = true
	}

	close(){
		//close the stream, and let the readFiber read any remaning buffered content
		_open = false
		if(_readFiber) _readFiber.call()
	}

	iterate(self){
      if(_open == null){
         //Stream has not been opened yet
         _readFiber = Fiber.current
         Fiber.yield()
         return true
      }
      return _open || hasBuffered
   }

	iteratorValue(self){
		//read a chunk from the buffer
		
		if(!hasBuffered){
			//if the buffer is empty, yield the read Fiber
			Fiber.yield()

			//when we resume, re-call this method to try again to get content
			return iteratorValue(self)
		} else {
			if(_buffer.bytes.count < _chunkSize){
				if(!readPartialChunk && _open){
					//if we're only reading fully sized chunks, but we don't have enough buffered
					//yeild and try again once we've read more
					Fiber.yield()
					return iteratorValue(self)
				}

				var returnedChunk = _buffer
				_buffer = ""
				return returnedChunk
			}

			var returnedChunk = _buffer[0..._chunkSize]
			_buffer = _buffer[_chunkSize..-1]
			return returnedChunk
		}
	}
}
