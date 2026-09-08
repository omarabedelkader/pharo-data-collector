"
A GTEventCollectorsTest is a test class for testing the behavior of GTEventCollectors
"
Class {
	#name : 'EREventCollectorsTest',
	#superclass : 'TestCase',
	#instVars : [
		'collectors'
	],
	#category : 'EventRecorder-Tests-Support',
	#package : 'EventRecorder-Tests',
	#tag : 'Support'
}

{ #category : 'running' }
EREventCollectorsTest >> setUp [
	super setUp.
	collectors := EREventCollectors new.
]

{ #category : 'tests' }
EREventCollectorsTest >> testAddingASingleCollector [

	collectors add: EREventCollector new.
	self assert: collectors size equals: 1.
]

{ #category : 'tests' }
EREventCollectorsTest >> testAddingTwiceTheSameCollectorIsIgnored [
	| collector |
	collector := EREventCollector new.
	collectors add: collector.
	collectors add: collector.
	self assert: collectors size equals: 1.
]

{ #category : 'tests' }
EREventCollectorsTest >> testAddingTwoDifferentCollectors [

	collectors add: EREventCollector new.
	collectors add: EREventCollector new.
	self assert: collectors size equals: 2.
]

{ #category : 'tests' }
EREventCollectorsTest >> testByDefaultCollectorsAreEmpty [

	self assert: collectors size equals: 0.
]

{ #category : 'tests' }
EREventCollectorsTest >> testEnsureCollectorAreIteratedInAdditionOrder [
	"Ensure that collectors are iterated in the same order as they are added."

	| collector1 collector2 iteratedCollectors |
	collector1 := EREventCollector new.
	collector2 := EREventCollector new.
	collectors add: collector2.
	collectors add: collector1.
	iteratedCollectors := OrderedCollection new.
	collectors do: [ :eachCollector | iteratedCollectors addLast: eachCollector ].
	self assert: iteratedCollectors size equals: 2.
	self assert: iteratedCollectors first identicalTo: collector2.
	self assert: iteratedCollectors second == collector1
]

{ #category : 'tests' }
EREventCollectorsTest >> testEnsureCollectorAreIteratedInAdditionOrder2 [
	"Ensure that collectors are iterated in the same order as they are added."

	| collector1 collector2 iteratedCollectors |
	collector1 := EREventCollector new.
	collector2 := EREventCollector new.
	collectors add: collector1.
	collectors add: collector2.
	iteratedCollectors := OrderedCollection new.
	collectors do: [ :eachCollector | iteratedCollectors addLast: eachCollector ].
	self assert: iteratedCollectors size equals: 2.
	self assert: iteratedCollectors first identicalTo: collector1.
	self assert: iteratedCollectors second == collector2
]
