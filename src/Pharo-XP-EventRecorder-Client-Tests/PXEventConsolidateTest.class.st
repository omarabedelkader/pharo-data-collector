Class {
	#name : #PXEventConsolidateTest,
	#superclass : #TestCase,
	#category : #'Pharo-XP-EventRecorder-Client-Tests'
}

{ #category : #private }
PXEventConsolidateTest >> collectorForParticipant: participantId [

	^ PXEventCollector new
		url: 'http://localhost:8008/events' asZnUrl;
		category: 'category';
		experienceId: 'experience';
		participantUUID: participantId;
		taskOrSurveyId: 'task';
		yourself
]

{ #category : #tests }
PXEventConsolidateTest >> testCollectorsWithDifferentMetadataAreNotMerged [

	| first second consolidated |
	first := self collectorForParticipant: 'participant-1'.
	second := self collectorForParticipant: 'participant-2'.
	first add: 1.
	second add: 2.

	consolidated := PXEventConsolidate new
		collectors: { first. second };
		consolidated.

	self assert: consolidated size equals: 2.
	self assert: (consolidated collect: #participantUUID) asSet size equals: 2
]

{ #category : #tests }
PXEventConsolidateTest >> testCollectorsWithSameMetadataAreMerged [

	| first second consolidated |
	first := self collectorForParticipant: 'participant-1'.
	second := self collectorForParticipant: 'participant-1'.
	first add: 1.
	second add: 2.

	consolidated := PXEventConsolidate new
		collectors: { first. second };
		consolidated.

	self assert: consolidated size equals: 1.
	self assert: consolidated first size equals: 2
]
