class StreamFlags {
	static readable  { 0x01 }
	static writeable { 0x02 }
}

class Stream {
	bufferSize { _bufferSize }
	bytesBuffered { _buffer.bytes.count }
	hasBuffered { this.bytesBuffered != 0 }
	open { _open }
	readable { _readable }
	writeable { _writeable }

	bufferSize=(n) {
		if(!_writeable){
			Fiber.abort("Can only set the buffer size of a writable Stream")
		}

		if(n < _buffer.bytes.count ){
			_bufferSize = _buffer.bytes.count
		} else {
			_bufferSize = n
		}
	}

	setup(){
		_buffer = ""
		_bufferSize = 1024
		_readable = false
		_writeable = false
	}

	construct new(){ 
		setup()
	}

	construct new(flags){
		setup()

		if( flags & StreamFlags.readable != 0 ){
			_readable = true
		}

		if(flags & StreamFlags.writeable != 0 ){ 
			_writeable = true
		}
	}

	open() {
		if(_writeable){
			// can we open the Stream from wren land?
			if(_open == null){
				_open = true
			}
		} else {
			Fiber.abort("Can only open a Stream if it is writeable")
		}
	}

	close() {
		if(_writeable){
			// can we open the Stream from wren land?
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
		if(!_writeable){
			Fiber.abort("Can not create a writing interface for a non-writeable Stream")
		}

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
		if(!_readable){
			Fiber.abort("Can not create a reading interface for a non-readable Stream")
		}

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
