class StreamChunk {
	construct new(){ }
	construct new(from){
		if(from is StreamChunk){
			_value = from.value
		} else {
			_value = from
		}
	}
}

class ReadableStreamChunk is StreamChunk {
	value { _value }
	construct new(value){
		super(value)
	}
}

class WriteableStreamChunk is StreamChunk {
	value { _value }
	value=(x){ _value = x}
	construct new(){ 
		super()
	}
	construct new(value){
		super(value)
	}
}
