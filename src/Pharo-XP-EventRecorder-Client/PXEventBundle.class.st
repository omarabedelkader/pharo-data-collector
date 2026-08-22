"
I specialize EREventBundle to use a dedicated multi bundle in order to serialize data related to PX experiments.
"
Class {
	#name : #PXEventBundle,
	#superclass : #EREventBundle,
	#instVars : [
		'experienceId',
		'participantUUID',
		'taskOrSurveyId'
	],
	#category : #'Pharo-XP-EventRecorder-Client'
}

{ #category : #accessing }
PXEventBundle >> experienceId [

	^ experienceId
]

{ #category : #accessing }
PXEventBundle >> experienceId: anObject [

	experienceId := anObject
]

{ #category : #'instance creation' }
PXEventBundle >> newMultiBundle [ 
	^PXEventMultiBundle new
]

{ #category : #accessing }
PXEventBundle >> participantUUID [

	^ participantUUID
]

{ #category : #accessing }
PXEventBundle >> participantUUID: anObject [

	participantUUID := anObject
]

{ #category : #accessing }
PXEventBundle >> taskOrSurveyId [

	^ taskOrSurveyId
]

{ #category : #accessing }
PXEventBundle >> taskOrSurveyId: anObject [

	taskOrSurveyId := anObject
]
