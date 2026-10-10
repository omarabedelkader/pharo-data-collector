"
A GTEventUnpackingTest is a test class for testing the behavior of GTEventUnpacking
"
Class {
	#name : 'EREventUnpackingTest',
	#superclass : 'TestCase',
	#instVars : [
		'unpacking',
		'collector',
		'unpackedData',
		'initialData',
		'bundle'
	],
	#category : 'EventRecorder-Tests-Support',
	#package : 'EventRecorder-Tests',
	#tag : 'Support'
}

{ #category : 'running' }
EREventUnpackingTest >> setUp [

	super setUp.
	initialData := #('Pharo' 'Team' 2015).
	collector := EREventCollector new.
	initialData do: [ :each | collector add: each ].
	self flag: #SD. "using a global will force to juggle around it :("
	unpacking := EREventUnpacking default.
]

{ #category : 'tests' }
EREventUnpackingTest >> testUnpack [

	bundle := EREventPacking default pack: collector.
	unpackedData := unpacking unpack: bundle data.
	self assert: unpackedData class equals: EREventAnnouncement.
	self assert: unpackedData unpackedData asArray equals: initialData.
]

{ #category : 'tests' }
EREventUnpackingTest >> testUnpack2 [
	self should: [ unpacking unpack: initialData ] raise: EREventUnpackingError
]

{ #category : 'tests' }
EREventUnpackingTest >> testUnpack3 [
	bundle := EREventPacking default pack: collector.
	unpacking := EREventUnpacking new.
	self should: [ unpacking unpack: bundle data ] raise: EREventInitializationError
]

{ #category : 'tests' }
EREventUnpackingTest >> testUnpackSton [
	bundle := EREventPacking ston pack: collector.
	unpackedData := unpacking unpack: bundle data.
	self assert: unpackedData class equals: EREventAnnouncement.
	self assert: unpackedData unpackedData asArray equals: initialData.
]
