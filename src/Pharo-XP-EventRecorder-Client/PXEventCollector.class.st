"
I collect events for a Pharo-XP experiment and attach the experiment,
participant, and task/survey identifiers required by the PX server.
"
Class {
	#name : 'PXEventCollector',
	#superclass : 'EREventCollector',
	#instVars : [
		'experienceId',
		'participantUUID',
		'taskOrSurveyId'
	],
	#category : 'Pharo-XP-EventRecorder-Client',
	#package : 'Pharo-XP-EventRecorder-Client'
}

{ #category : 'accessing' }
PXEventCollector >> experienceId [

	^ experienceId
]

{ #category : 'accessing' }
PXEventCollector >> experienceId: anObject [

	experienceId := anObject
]

{ #category : 'instance creation' }
PXEventCollector >> newBundle [

	^ PXEventBundle new
]

{ #category : 'instance creation' }
PXEventCollector >> newBundleForPacking [

	| bundle |
	bundle := super newBundleForPacking.
	bundle
		experienceId: self experienceId;
		taskOrSurveyId: self taskOrSurveyId;
		participantUUID: self participantUUID.
	^ bundle
]

{ #category : 'accessing' }
PXEventCollector >> participantUUID [

	^ participantUUID
]

{ #category : 'accessing' }
PXEventCollector >> participantUUID: anObject [

	participantUUID := anObject
]

{ #category : 'tools registry' }
PXEventCollector >> register [

	PXEventRecorder uniqueInstance addCollector: self
]

{ #category : 'accessing' }
PXEventCollector >> taskOrSurveyId [

	^ taskOrSurveyId
]

{ #category : 'accessing' }
PXEventCollector >> taskOrSurveyId: anObject [

	taskOrSurveyId := anObject
]

{ #category : 'accessing' }
PXEventCollector >> url [

	^ url ifNil: [ url := PXEventRecorder endpoint ]
]
