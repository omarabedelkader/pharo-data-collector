"
A GTEventCollectorTest is a test class for testing the behavior of GTEventCollector
"
Class {
	#name : 'EREventCollectorTest',
	#superclass : 'TestCase',
	#instVars : [
		'collector'
	],
	#category : 'EventRecorder-Tests-Core',
	#package : 'EventRecorder-Tests',
	#tag : 'Core'
}

{ #category : 'running' }
EREventCollectorTest >> setUp [
	super setUp.
	collector := EREventCollector new
]

{ #category : 'tests' }
EREventCollectorTest >> testBundleActuallyCollectAndFlush [

	| collected |
	collector add: ERDummyEvent new.
	collector add: ERDummyEvent new.
	collected := collector bundle.
	self assert: collected size equals: 2.
	self assert: collector bundle isEmpty.
]

{ #category : 'tests' }
EREventCollectorTest >> testBundleOfANewCollectorIsEmpty [

	self assert: collector bundle isEmpty
]

{ #category : 'tests' }
EREventCollectorTest >> testByDefaultCollectorLiberated [

	self assert: collector isLiberated
]

{ #category : 'tests' }
EREventCollectorTest >> testIsLiberated3 [
	"The occupant has to be empty."
	collector occupant: self.
	self deny: collector isLiberated.
]

{ #category : 'tests' }
EREventCollectorTest >> testLiberate [
	collector liberate.
	self assert: collector isLiberated
]

{ #category : 'tests' }
EREventCollectorTest >> testLiberate2 [
	collector occupant: self.
	self deny: collector isLiberated.
	collector liberate.
	self assert: collector isLiberated
]

{ #category : 'tests' }
EREventCollectorTest >> testPrintOn [
	self assert: (String streamContents: [ :stream | collector printOn: stream ]) notEmpty.
]

{ #category : 'tests' }
EREventCollectorTest >> testUpdateAnnouncement [
	| announcement announcement2 |
	collector updateAnnouncementBlock: [ :anAnnouncement | 
		anAnnouncement at: #testUpdateAnnouncement put: 42 ].
	announcement := EREventAnnouncement new.
	self assert: (announcement at: #testUpdateAnnouncement) isNil.
	announcement2 := collector updateAnnouncement: announcement.
	self assert: announcement == announcement2.
	self assert: (announcement at: #testUpdateAnnouncement) equals: 42.
]

{ #category : 'tests' }
EREventCollectorTest >> testUrl [
	self assert: collector url notNil.
	self assert: collector url equals: ERPrivacySettings url.
]

{ #category : 'tests' }
EREventCollectorTest >> testWhenDataIsSetAndNotConsumedTheCollectorIsNotLiberated [
	"The collection of events has to be empty."
	
	collector add: 42.
	self deny: collector isLiberated.
]

{ #category : 'tests' }
EREventCollectorTest >> testWhenNotSetCategoryIsDefault [

	self 
		assert: collector category 
		equals: collector defaultCategory
]
