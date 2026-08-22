Class {
	#name : #PXServerFileStorageTest,
	#superclass : #EREventRecorderFileStorageTest,
	#instVars : [
		'metadata'
	],
	#category : #'Pharo-XP-EventRecorder-Server-Tests'
}

{ #category : #running }
PXServerFileStorageTest >> setUp [

	super setUp.
	storage := PXServerFileStorage new.
	storage directory: fileSystem workingDirectory.
	metadata := Dictionary new
		at: PXEventMultiBundle categoryFieldName put: 'category';
		at: PXEventMultiBundle experienceIdFieldName put: 'experienceId';
		at: PXEventMultiBundle participantUUIDFieldName put: 'participantUUID';
		at: PXEventMultiBundle taskOrSurveyIdFieldName put: 'taskOrSurveyId';
		yourself
]

{ #category : #tests }
PXServerFileStorageTest >> testAtCategoryPut [

	| location input |
	input := #[ 1 2 3 4 ].
	location := storage atCategory: (STONJSON toString: metadata) put: input.
	self assertLocation: location input: input
]

{ #category : #tests }
PXServerFileStorageTest >> testBuildDirectoryIn [

	| directory segments |
	directory := storage buildDirectory: metadata in: storage directory.
	segments := directory pathSegments.
	self assert: directory exists.
	self assert: segments size equals: 4.
	self assert: segments first equals: (metadata at: PXEventMultiBundle categoryFieldName).
	self assert: segments second equals: (metadata at: PXEventMultiBundle experienceIdFieldName).
	self assert: segments third equals: (metadata at: PXEventMultiBundle participantUUIDFieldName).
	self assert: segments fourth equals: (metadata at: PXEventMultiBundle taskOrSurveyIdFieldName)
]

{ #category : #tests }
PXServerFileStorageTest >> testRejectsPathTraversal [

	metadata at: PXEventMultiBundle participantUUIDFieldName put: '../outside'.
	self
		should: [ storage buildDirectory: metadata in: storage directory ]
		raise: Error
]

{ #category : #tests }
PXServerFileStorageTest >> testPut [

	self
		should: [ storage put: #[ 1 2 3 4 ] ]
		raise: Error
]
