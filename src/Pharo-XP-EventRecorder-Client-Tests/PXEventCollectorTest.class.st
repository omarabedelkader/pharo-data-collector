Class {
	#name : #PXEventCollectorTest,
	#superclass : #EREventCollectorTest,
	#category : #'Pharo-XP-EventRecorder-Client-Tests'
}

{ #category : #running }
PXEventCollectorTest >> setUp [

	super setUp.
	collector := PXEventCollector new.
	collector url: #url.
	collector category: #category.
	collector experienceId: #experienceId.
	collector taskOrSurveyId: #taskOrSurveyId.
	collector participantUUID: #participantUUID
]

{ #category : #tests }
PXEventCollectorTest >> testNewBundle [
	self assert: collector newBundle class equals: PXEventBundle 
]

{ #category : #tests }
PXEventCollectorTest >> testNewBundleForPacking [
	|bundle|
	bundle := collector newBundleForPacking.
	self assert: bundle url equals: collector url.
	self assert: bundle category equals: collector category.
	self assert: bundle experienceId equals: collector experienceId.
	self assert: bundle taskOrSurveyId equals: collector taskOrSurveyId.
	self assert: bundle participantUUID equals: collector participantUUID
]
