class StreamFlags {
	static readable         { 0x01 } //the Stream is readable from wren-land
	static writeable        { 0x02 } //the Stream is writeable from wren-land
	static readPartialChunk { 0x04 } //the Stream can output chunks that are smaller than the chunkSize
}

