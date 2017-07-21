class StreamFlags {
	static readable       { 0x01 }
	static writeable      { 0x02 }
	static exclusiveRead  { 0x04 }
	static exclusiveWrite { 0x08 }
}

class Stream {
	bufferSize { _bufferSize }
	bytesBuffered { _buffer.bytes.count }
	exclusiveRead { _flags & StreamFlags.exclusiveRead != 0 }
	exclusiveWrite { _flags & StreamFlags.exclusiveWrite != 0 }
	hasBuffered { this.bytesBuffered != 0 }
	open { _open }
	readable { _flags & StreamFlags.readable != 0 }
	writeable { _flags & StreamFlags.writeable != 0 }

	bufferSize=(n) {
		if(!this.writeable){
			Fiber.abort("Can only set the buffer size of a writable Stream")
		}

		if(n < _buffer.bytes.count ){
			_bufferSize = _buffer.bytes.count
		} else {
			_bufferSize = n
		}
	}

	construct new(flags){
		_buffer = ""
		_bufferSize = 1024
		_open == null //has not been opened yet
		_readInterfacesCreated = 0
		_writeInterfacesCreated = 0

		_flags = flags
	}

	open() {
		if(this.writeable){
			// can we open the Stream from wren land?
			if(_open == null){
				_open = true
			}
		} else {
			Fiber.abort("Can only open a Stream if it is writeable")
		}
	}

	close() {
		if(this.writeable){
			// can we close the Stream from wren land?
			if(_open){
				_open = false
			}
		} else {
			Fiber.abort("Can only close a Stream if it is writeable")
		}
	}

	addListener(fn){
		if(!_listeners){
			_listeners = [ fn ]
		} else {
			_listeners.add(fn)
		}
	}

	writingInterface {
		if(!this.writeable){
			Fiber.abort("Can not create a writing interface for a non-writeable Stream")
		}

		if( _writeInterfacesCreated > 0 && this.exclusiveWrite ){
			Fiber.abord("Can not create multipul writing interfaces for an exclusive-write Stream")
		}

		_writeInterfacesCreated = _writeInterfacesCreated + 1

		var input = null
		var unBufferedRemainder = null

		var fiber = Fiber.new {
			var input = Fiber.yield()

			while(_open) { 
				var spaceLeftInBuffer = _bufferSize - _buffer.bytes.count

				if( input.bytes.count <= spaceLeftInBuffer ){
					_buffer = _buffer + input
				} else {
					_buffer = _buffer + input[0...spaceLeftInBuffer]
					unBufferedRemainder = input[spaceLeftInBuffer..-1]
				}

				_listeners.each { | fn | fn.call() }

				input = Fiber.yield(unBufferedRemainder)
			}
		}

		// just start the fiber off, otherwise the first thing written to it will be lost
		fiber.call()

		return fiber
	}

	readingInterface {
		if(!this.readable){
			Fiber.abort("Can not create a reading interface for a non-readable Stream")
		}

		if( _readInterfacesCreated > 0 && this.exclusiveread ){
			Fiber.abord("Can not create multipul reading interfaces for an exclusive-read Stream")
		}

		_readInterfacesCreated =  _readInterfacesCreated + 1 

		var fiber = Fiber.new {
			var output = null
			var i = Fiber.yield()

			while(_open){
				if(_buffer.bytes.count >= i){
					output = _buffer[0...i]
					_buffer = _buffer[i..-1]
				} else {
					output = _buffer
					_buffer = ""
				}

				i = Fiber.yield(output)
			}
		}

		// just start the fiber off, otherwise we'll always get null on first call()
		fiber.call()

		return fiber
	}

}
