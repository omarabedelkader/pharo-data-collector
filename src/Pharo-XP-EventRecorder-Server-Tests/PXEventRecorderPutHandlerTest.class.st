Class {
	#name : #PXEventRecorderPutHandlerTest,
	#superclass : #TestCase,
	#instVars : [
		'handler',
		'entity',
		'metadataString'
	],
	#category : #'Pharo-XP-EventRecorder-Server-Tests'
}

{ #category : #private }
PXEventRecorderPutHandlerTest >> buildMetadata [

	^ Dictionary new
		at: PXEventMultiBundle categoryFieldName put: 'category';
		at: PXEventMultiBundle experienceIdFieldName put: 'experienceId';
		at: PXEventMultiBundle participantUUIDFieldName put: 'participantUUID';
		at: PXEventMultiBundle taskOrSurveyIdFieldName put: 'taskOrSurveyId';
		yourself
]

{ #category : #private }
PXEventRecorderPutHandlerTest >> entityWithMetadataString: aString [

	^ ZnMultiPartFormDataEntity new
		addPart: (ZnMimePart
			fieldName: PXEventMultiBundle categoryFieldName
			value: aString);
		addPart: (ZnMimePart
			fieldName: PXEventMultiBundle dataFieldName
			entity: (ZnEntity bytes: '42' asByteArray));
		yourself
]

{ #category : #running }
PXEventRecorderPutHandlerTest >> setUp [

	handler := PXEventRecorderPutHandler new.
	metadataString := STONJSON toString: self buildMetadata.
	entity := self entityWithMetadataString: metadataString
]

{ #category : #tests }
PXEventRecorderPutHandlerTest >> testDetectFieldNamedInParts [

	self
		assert: (handler
			detectFieldNamed: PXEventMultiBundle categoryFieldName
			inParts: entity parts) fieldValue
		equals: metadataString.
	self
		should: [ handler detectFieldNamed: 'test' inParts: entity parts ]
		raise: NotFound
]

{ #category : #tests }
PXEventRecorderPutHandlerTest >> testHasCategoryAndDataParts [

	self assert: (handler hasCategoryAndDataParts: entity parts)
]

{ #category : #tests }
PXEventRecorderPutHandlerTest >> testRejectsInvalidJSONMetadata [

	entity := self entityWithMetadataString: 'not-json'.
	self deny: (handler hasCategoryAndDataParts: entity parts)
]

{ #category : #tests }
PXEventRecorderPutHandlerTest >> testRejectsMissingMetadata [

	| metadata |
	metadata := self buildMetadata.
	metadata removeKey: PXEventMultiBundle taskOrSurveyIdFieldName.
	entity := self entityWithMetadataString: (STONJSON toString: metadata).
	self deny: (handler hasCategoryAndDataParts: entity parts)
]

{ #category : #tests }
PXEventRecorderPutHandlerTest >> testRejectsNonStringMetadata [

	| metadata |
	metadata := self buildMetadata.
	metadata at: PXEventMultiBundle taskOrSurveyIdFieldName put: 42.
	entity := self entityWithMetadataString: (STONJSON toString: metadata).
	self deny: (handler hasCategoryAndDataParts: entity parts)
]
