"
I represent an unpacking object that is able to receive serialized objects, e.g., FUEL or STON, and tries all available packing systems to unpack the serialized objects.

Others can ask me for materializing an object by sending me #unpack:. I resent the request to EREventPacking objects and if anyone is able to materialize it, I will return the materialized object. Otherwise, I raise an error.

Collaborators Part: EREventPacking, EREventInitializationError, EREventUnpackingError.

Public API and Key Messages

- unpack: aByteArray
- addPacking: anEventPacking
- how to create instances: #default on the class side.

Example:
	(EREventUnpacking default
		unpack: (EREventPacking ston 
					pack: (EREventCollector new 
							add: 1; add: 2; add: 3; yourself)) 
			data) unpackedData
 
Internal Representation and Key Implementation Points.

    Instance Variables
	packings:		<OrderedCollection>

"
Class {
	#name : 'EREventUnpacking',
	#superclass : 'Object',
	#instVars : [
		'packings'
	],
	#category : 'EventRecorder-Support',
	#package : 'EventRecorder',
	#tag : 'Support'
}

{ #category : 'instance creation' }
EREventUnpacking class >> default [
	^ self new
			addPackingKind: EREventPacking ston;
			yourself
]

{ #category : 'instance creation' }
EREventUnpacking class >> randomUnpack [
	"self randomUnpack"
	
	self default unpackFile: (EREventRecorder localStoragePath allFiles atRandom)
]

{ #category : 'adding' }
EREventUnpacking >> addPackingKind: anEventPacking [

	self packingKinds addLast: anEventPacking
]

{ #category : 'accessing' }
EREventUnpacking >> packingKinds [
	^ packings ifNil: [ packings := OrderedCollection new ]
]

{ #category : 'packing' }
EREventUnpacking >> safeUnpackDirectory: aFileReference [
	"self default safeUnpackDirectory: EREventRecorder localStoragePath"
	
	| unpackedData exceptions |
	exceptions := OrderedCollection new.
	[ unpackedData := self unpackDirectory: aFileReference ] 
		on: EREventUnpackingError 
		do: [ :exception |
			exceptions addLast: exception.
			exception resume ].
	^ unpackedData -> exceptions
]

{ #category : 'packing' }
EREventUnpacking >> unpack: aByteArray [

	| exceptions |
	exceptions := OrderedCollection new: self packingKinds size.
	self packingKinds do: [ :eachEventPacking |
		[ ^ eachEventPacking unpack: aByteArray ] on: Error
			do: [ :exception | exceptions addLast: exception ] ].
	exceptions
		ifEmpty: [ EREventInitializationError signal: 'Uninitialized unpacking system' ]
		ifNotEmpty: [ EREventUnpackingError 
								signal: 'Cannot unpack data' 
								data: aByteArray 
								errors: exceptions ].
	"In case of resumed exception it returns nil object."
	^ nil
]

{ #category : 'packing' }
EREventUnpacking >> unpackDirectory: aFileReference [
	"self default unpackDirectory: EREventRecorder localStoragePath"
	
	^ aFileReference asFileReference allFiles 
			reject:  [ :eachFile | eachFile basename = '.DS_Store' ]
			thenCollect: [ :eachFile | self unpackFile: eachFile  ]
			
]

{ #category : 'packing' }
EREventUnpacking >> unpackFile: aFileReference [
	"self default unpackFile: EREventRecorder localStoragePath allFiles atRandom"
	
	^ [ self unpack: (aFileReference binaryReadStreamDo: [ :aStream |  aStream contents ]) ]
		on: EREventUnpackingError do: [ :anException |
			anException data: aFileReference.
			anException pass ]
]
