class StreamFlags {
	static readable  { 0x01 }
	static writeable { 0x02 }
	static asBytes   { 0x04 }
}

class StreamDelimiter {
	static all       { 1 } //return everything buffered
	static character { 2 } //return a single character 
	static custom    { 3 } //use a custom delimeter ( e.g: ',' ';', '.' )
	static line      { 4 } //return a line: i.e: until the next instance of /n
}

class Stream {
	asBytes { _asBytes }
	delimiterCharacter { _delimiterCharacter }
	delimiter { _delimiter }
	open { _open }
	readable { _readable }
	writeable { _writeable }
	hasBuffered { _buffer.count != 1 }

	setup(){
		_asBytes = false
		_buffer = ""
		_delimiterCharacter = "\n"
		_delimiter = StreamDelimiter.line
		_readable = false
		_writeable = false
	}

	construct new(){ 
		setup()
	}

	construct new(flags){
		setup()

		_asBytes = flags & StreamFlags.asBytes != 0

		if( flags & StreamFlags.readable != 0 ){
			_readable = true
		}

		if(flags & StreamFlags.writeable != 0 ){ 
			_writeable = true
		}
	}

	open() {
		if(_writeable){
			// can we open the stream from wren land?
			if(_open == null){
				_open = true
			}
		} else {
			Fiber.abort("Can only open a fiber if it is writeable")
		}
	}

	close() {
		if(_writeable){
			// can we open the stream from wren land?
			if(_open){
				_open = false
			}
		} else {
			Fiber.abort("Can only close a fiber if it is writeable")
		}
	}

	getOutputChunk(){
		var output = ""
		if(_delimiter == StreamDelimiter.all){
			output = _buffer
			_buffer = ""
		}

		if(_delimiter == StreamDelimiter.character){
			output = _buffer[0]
			_buffer = _buffer[1..-1]
		}

		if(_delimiter == StreamDelimiter.custom || _delimiter == StreamDelimiter.line){
			var i = _buffer.indexOf(_delimiterCharacter)

			if( i != -1 ){
				output = _buffer[0..i]
				_buffer = _buffer[(i + 1)..-1]
			} else {
				output = _buffer
				_buffer = ""
			}
		}

		return output
	}

	interface(flags){
		var interfaceReadable = false
		var interfaceWriteable = false

		if( flags & StreamFlags.readable != 0 ){
			if(!_readable){
				Fiber.abort("Can no create a readable interface on a non-readable stream")
			}
			interfaceReadable = true
		}

		if(flags & StreamFlags.writeable != 0 ){ 
			if(!_writeable){
				Fiber.abort("Can no create a writeable interface on a non-writeable stream")
			}
			interfaceWriteable = true
		}

		var input = null
		var output = null

		return Fiber.new {
			while (_open){
				/*System.print("1 [%(interfaceReadable)] {%(input)}; (%(output)), [%(_buffer)]")*/

				//process the input
				if(input){
					if(interfaceWriteable){
						_buffer = _buffer + input

						_listeners.each { |callback| callback.call() }
					} else {
						Fiber.abort("Can not write to a non-writeable interface")
					}
				}

				/*System.print("2 [%(interfaceReadable)] {%(input)}; (%(output)), [%(_buffer)]")*/

				if(interfaceReadable){
					//create an output
					//
					//we need to itterate through our buffer
					//until we find a symbol that matches the stream's delimiter

					output = getOutputChunk()
				}

				/*System.print("3 [%(interfaceReadable)] {%(input)}; (%(output)), [%(_buffer)]")*/

				input = Fiber.yield(output)
			}
		}
	}

	addListener(fn){
		if(!_listeners){
			_listeners = [ fn ]
		} else {
			_listeners.add(fn)
		}

	}
}

var stream = Stream.new( StreamFlags.writeable | StreamFlags.readable )
var readingInterface = stream.interface( StreamFlags.readable)
var writeingInterface = stream.interface( StreamFlags.writeable)

stream.addListener( Fn.new {
	System.print("something was wrote!")
} )

stream.open()

System.print("warmup")
writeingInterface.call()
System.print("\nreal 1")
writeingInterface.call("one")
System.print("\nreal 2")
writeingInterface.call("two\nthree")
System.print("\nreal 3")
writeingInterface.call("four\nfive\nSix")

System.print(readingInterface.call())
System.print(readingInterface.call())
System.print(readingInterface.call())

stream.close()
