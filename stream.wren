import "./streamBuffer" for StreamBuffer
import "./streamInputSequence" for StreamInputSequence
import "./streamOutputSequence" for StreamOutputSequence

class Stream {
	input { StreamInputSequence.new(this) }
	open { _open }
	output { 
		_outputSequence= StreamOutputSequence.new(this)
		return _outputSequence
	}

	construct new(flags) {
		_flags = flags
	}

	open(){
		_open = true
	}

	close(){
		_open = false
	}

	enqueueChunk(chunk){
		_outputSequence.enqueueChunk(chunk)
	}
}
