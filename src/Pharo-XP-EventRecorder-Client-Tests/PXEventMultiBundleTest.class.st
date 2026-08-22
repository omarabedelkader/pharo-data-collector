Class {
	#name : #PXEventMultiBundleTest,
	#superclass : #EREventMultiBundleTest,
	#instVars : [
		'pxBundle'
	],
	#category : #'Pharo-XP-EventRecorder-Client-Tests'
}

{ #category : #running }
PXEventMultiBundleTest >> setUp [

	super setUp.
	pxBundle := PXEventBundle new
		url: 'http://localhost:8008/events' asZnUrl;
		category: #c1;
		experienceId: #px;
		participantUUID: #pUUID;
		taskOrSurveyId: #tosID;
		data: #[ 1 2 3 ];
		yourself.
	multiBundle := PXEventMultiBundle new
]

{ #category : #tests }
PXEventMultiBundleTest >> testMissingMetadataFailsBeforeSending [

	pxBundle participantUUID: nil.
	self
		should: [ multiBundle updateEntity: ZnMultiPartFormDataEntity new forSingleBundle: pxBundle ]
		raise: Error
]

{ #category : #tests }
PXEventMultiBundleTest >> testUpdateEntityForSingleBundle [

	| metadata |
	entity := ZnMultiPartFormDataEntity new.
	multiBundle updateEntity: entity forSingleBundle: pxBundle.

	metadata := STONJSON fromString: (entity parts detect: [ :each |
		each fieldName = PXEventMultiBundle categoryFieldName ]) fieldValue.
	self
		assert: (metadata at: PXEventMultiBundle categoryFieldName)
		equals: pxBundle category asString.
	self
		assert: (metadata at: PXEventMultiBundle experienceIdFieldName)
		equals: pxBundle experienceId asString.
	self
		assert: (metadata at: PXEventMultiBundle participantUUIDFieldName)
		equals: pxBundle participantUUID asString.
	self
		assert: (metadata at: PXEventMultiBundle taskOrSurveyIdFieldName)
		equals: pxBundle taskOrSurveyId asString.

	self
		assert: (entity parts detect: [ :each |
			each fieldName = PXEventMultiBundle dataFieldName ]) contents
		equals: pxBundle entity contents
]
