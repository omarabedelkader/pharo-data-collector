"
I serialize or materialize objects using STON framework. `EREventPacking ston` creates an instance of me.
"
Class {
	#name : 'ERStonPacking',
	#superclass : 'EREventPacking',
	#category : 'EventRecorder-Support',
	#package : 'EventRecorder',
	#tag : 'Support'
}

{ #category : 'private' }
ERStonPacking >> materialize: aByteArray [
	| stream gzstream |
	stream := aByteArray asString readStream.
	gzstream := GZipReadStream on: stream.
	^ [ STON fromStream: gzstream ] ensure: [ gzstream close. stream close ]
]

{ #category : 'private' }
ERStonPacking >> serialize: anObject [
	^ (String streamContents: [ :stream | | gzstream |
		gzstream := GZipWriteStream on: stream.
		[ STON put: anObject onStreamPretty: gzstream ]
			ensure: [ gzstream close ] ]) asByteArray
]

{ #category : 'accessing' }
ERStonPacking >> technologyName [
	^ 'ston'
]
