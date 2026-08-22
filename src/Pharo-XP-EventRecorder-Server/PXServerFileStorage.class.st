"
I persist PX event payloads under a directory hierarchy derived from validated
metadata:

  category / experienceId / participantUUID / taskOrSurveyId / file

Path segments are restricted to a conservative identifier character set so
request data cannot traverse outside the configured storage directory.
"
Class {
	#name : #PXServerFileStorage,
	#superclass : #EREventRecorderFileStorage,
	#category : #'Pharo-XP-EventRecorder-Server'
}

{ #category : #accessing }
PXServerFileStorage >> atCategory: aJSONString put: aByteArray [

	| metadata segments subDirectory fileName file |
	metadata := self metadataFromString: aJSONString.
	segments := self pathSegmentsFor: metadata.
	subDirectory := self buildDirectoryFromSegments: segments in: self directory.
	fileName := self newFileName.
	file := subDirectory / fileName.
	file binaryWriteStreamDo: [ :stream |
		stream nextPutAll: aByteArray ].
	^ String streamContents: [ :stream |
		segments do: [ :segment |
			stream
				nextPutAll: segment;
				nextPut: $/ ].
		stream nextPutAll: fileName ]
]

{ #category : #private }
PXServerFileStorage >> buildDirectory: metadata in: parent [

	^ self
		buildDirectoryFromSegments: (self pathSegmentsFor: metadata)
		in: parent
]

{ #category : #private }
PXServerFileStorage >> buildDirectoryFromSegments: segments in: parent [

	| directory |
	directory := parent.
	segments do: [ :segment |
		directory := directory / segment ].
	directory ensureCreateDirectory.
	^ directory
]

{ #category : #private }
PXServerFileStorage >> isSafePathSegment: aString [

	aString isEmpty ifTrue: [ ^ false ].
	(aString = '.' or: [ aString = '..' ]) ifTrue: [ ^ false ].
	^ aString allSatisfy: [ :character |
		character isAlphaNumeric or: [ '-_.@' includes: character ] ]
]

{ #category : #private }
PXServerFileStorage >> metadataFromString: aJSONString [

	| metadata |
	metadata := STONJSON fromString: aJSONString.
	(metadata isKindOf: Dictionary) ifFalse: [ self error: 'PX metadata must be a JSON object' ].
	^ metadata
]

{ #category : #private }
PXServerFileStorage >> newFileName [

	^ UUID new printString , '-' , DateAndTime now asUnixTime printString
]


{ #category : #private }
PXServerFileStorage >> pathSegmentsFor: metadata [

	^ PXEventMultiBundle metaDataFieldNames collect: [ :fieldName |
		self pathSegmentFor: metadata field: fieldName ]
]

{ #category : #accessing }
PXServerFileStorage >> put: aByteArray [

	self error: 'PX storage requires multipart metadata'
]

{ #category : #private }
PXServerFileStorage >> pathSegmentFor: metadata field: fieldName [

	| segment |
	segment := metadata
		at: fieldName
		ifAbsent: [ self error: 'Missing PX metadata: ', fieldName ].
	segment isString ifFalse: [ self error: 'PX metadata must be strings' ].
	(self isSafePathSegment: segment) ifFalse: [
		self error: 'Unsafe PX metadata path segment: ', fieldName ].
	^ segment
]
