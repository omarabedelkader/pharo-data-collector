"
I validate and persist multipart PUT requests produced by PXEventMultiBundle.
Only the four expected metadata fields are accepted and all values must be
non-empty strings.
"
Class {
	#name : #PXEventRecorderPutHandler,
	#superclass : #EREventRecorderPutHandler,
	#category : #'Pharo-XP-EventRecorder-Server'
}

{ #category : #private }
PXEventRecorderPutHandler >> detectFieldNamed: aFieldName inParts: aCollection [

	^ aCollection detect: [ :each | each fieldName = aFieldName ]
]

{ #category : #testing }
PXEventRecorderPutHandler >> hasCategoryAndDataParts: aCollection [

	| metadata |
	(super hasCategoryAndDataParts: aCollection) ifFalse: [ ^ false ].
	metadata := self metadataFromParts: aCollection.
	metadata ifNil: [ ^ false ].
	^ self isValidMetadata: metadata
]

{ #category : #testing }
PXEventRecorderPutHandler >> isApplicationOctetStream: aZnRequest [

	"PX events require multipart metadata; raw octet-stream uploads are rejected."
	^ false
]

{ #category : #testing }
PXEventRecorderPutHandler >> isValidMetadata: metadata [

	(metadata isKindOf: Dictionary) ifFalse: [ ^ false ].
	metadata size = PXEventMultiBundle metaDataFieldNames size ifFalse: [ ^ false ].
	^ PXEventMultiBundle metaDataFieldNames allSatisfy: [ :fieldName |
		(metadata includesKey: fieldName) and: [
			| value |
			value := metadata at: fieldName.
			value isString and: [ value isEmpty not ] ] ]
]

{ #category : #private }
PXEventRecorderPutHandler >> metadataFromParts: aCollection [

	| metadataPart |
	metadataPart := [
		self
			detectFieldNamed: PXEventMultiBundle categoryFieldName
			inParts: aCollection ]
		on: NotFound
		do: [ ^ nil ].
	^ [ STONJSON fromString: metadataPart fieldValue ]
		on: Error
		do: [ nil ]
]
