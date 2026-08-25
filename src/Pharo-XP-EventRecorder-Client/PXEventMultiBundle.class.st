"
I extend EREventMultiBundle with the metadata required by Pharo-XP.
Metadata is encoded as JSON and every value is normalized to a string before
it is sent to the server.
"
Class {
	#name : 'PXEventMultiBundle',
	#superclass : 'EREventMultiBundle',
	#category : 'Pharo-XP-EventRecorder-Client',
	#package : 'Pharo-XP-EventRecorder-Client'
}

{ #category : 'accessing' }
PXEventMultiBundle class >> allFieldNames [

	^ {
		self categoryFieldName.
		self experienceIdFieldName.
		self participantUUIDFieldName.
		self taskOrSurveyIdFieldName.
		self dataFieldName }
]

{ #category : 'accessing' }
PXEventMultiBundle class >> categoryFieldName [

	^ 'category'
]

{ #category : 'accessing' }
PXEventMultiBundle class >> dataFieldName [

	^ 'data'
]

{ #category : 'accessing' }
PXEventMultiBundle class >> experienceIdFieldName [

	^ 'experienceId'
]

{ #category : 'accessing' }
PXEventMultiBundle class >> metaDataFieldNames [

	^ {
		self categoryFieldName.
		self experienceIdFieldName.
		self participantUUIDFieldName.
		self taskOrSurveyIdFieldName }
]

{ #category : 'accessing' }
PXEventMultiBundle class >> participantUUIDFieldName [

	^ 'participantUUID'
]

{ #category : 'accessing' }
PXEventMultiBundle class >> taskOrSurveyIdFieldName [

	^ 'taskOrSurveyId'
]

{ #category : 'private' }
PXEventMultiBundle >> metadataFor: aSingleBundle [

	^ Dictionary new
		at: self class categoryFieldName
			put: (self metadataStringFrom: aSingleBundle category field: self class categoryFieldName);
		at: self class experienceIdFieldName
			put: (self metadataStringFrom: aSingleBundle experienceId field: self class experienceIdFieldName);
		at: self class participantUUIDFieldName
			put: (self metadataStringFrom: aSingleBundle participantUUID field: self class participantUUIDFieldName);
		at: self class taskOrSurveyIdFieldName
			put: (self metadataStringFrom: aSingleBundle taskOrSurveyId field: self class taskOrSurveyIdFieldName);
		yourself
]

{ #category : 'private' }
PXEventMultiBundle >> metadataStringFrom: anObject field: fieldName [

	anObject ifNil: [ self error: 'Missing PX metadata: ', fieldName ].
	^ anObject asString
]

{ #category : 'private' }
PXEventMultiBundle >> updateEntity: aZnMultiPartFormDataEntity forSingleBundle: aSingleBundle [

	| metadata |
	metadata := self metadataFor: aSingleBundle.
	aZnMultiPartFormDataEntity
		addPart: (ZnMimePart
			fieldName: self class categoryFieldName
			value: (STONJSON toString: metadata));
		addPart: (ZnMimePart
			fieldName: self class dataFieldName
			entity: aSingleBundle entity)
]
