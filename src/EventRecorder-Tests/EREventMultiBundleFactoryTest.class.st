"
A GTEventMultiBundleFactoryTest is a test class for testing the behavior of GTEventMultiBundleFactory
"
Class {
	#name : 'EREventMultiBundleFactoryTest',
	#superclass : 'TestCase',
	#instVars : [
		'bundle1',
		'bundle2',
		'bundle3',
		'bundle4',
		'factory',
		'multiBundles',
		'multiBundle1',
		'multiBundle2'
	],
	#category : 'EventRecorder-Tests-Support',
	#package : 'EventRecorder-Tests',
	#tag : 'Support'
}

{ #category : 'accessing' }
EREventMultiBundleFactoryTest >> allBundles [
	^ { bundle1. bundle2. bundle3. bundle4 }
]

{ #category : 'private' }
EREventMultiBundleFactoryTest >> detectEvents [
	multiBundle1 := multiBundles first.
	multiBundle2 := multiBundles second.
	
]

{ #category : 'running' }
EREventMultiBundleFactoryTest >> setUp [
	super setUp.
	bundle1 := EREventBundle new 
		url: 'http://localhost/gt/events1' asZnUrl; category: #c1; data: #[1 2 3]; yourself.
	bundle2 := EREventBundle new 
		url: 'http://localhost/gt/events1' asZnUrl; category: #c1; data: #[4 5 6]; yourself.
	bundle3 := EREventBundle new 
		url: 'http://localhost/gt/events1' asZnUrl; category: #c2; data: #[7 8 9]; yourself.
	bundle4 := EREventBundle new 
		url: 'http://localhost/gt/events2' asZnUrl; category: #c1; data: #[10 11 12]; yourself.
	factory := EREventMultiBundleFactory new.
]

{ #category : 'tests' }
EREventMultiBundleFactoryTest >> testFromBundles [
	multiBundles := factory fromBundles: self allBundles.
	self assert: multiBundles size equals: 2.
	self detectEvents.
	self assert: multiBundle1 url equals: bundle1 url.
	self deny: multiBundle1 flushAndCollectedData isEmpty.
	self assert: multiBundle2 url equals: bundle4 url.
	self deny: multiBundle2 flushAndCollectedData isEmpty.
	self assert: multiBundle1 flushAndCollectedData size equals: 3.
	self assert: multiBundle2 flushAndCollectedData size equals: 1.
	self assert: multiBundle1 flushAndCollectedData first equals: bundle1.
	self assert: multiBundle1 flushAndCollectedData second equals: bundle2.
	self assert: multiBundle1 flushAndCollectedData third equals: bundle3.
	self assert: multiBundle2 flushAndCollectedData first equals: bundle4.

]

{ #category : 'tests' }
EREventMultiBundleFactoryTest >> testFromBundles2 [
	"#fromBundles: can also receive GTMultiBundle object. It should be consolidate too."
	multiBundles := factory fromBundles: self allBundles.
	multiBundles := factory fromBundles: (self allBundles copy asOrderedCollection
		addAll: multiBundles;
		yourself) asArray.
	self assert: multiBundles size equals: 2.
	self detectEvents.
	self assert: multiBundle1 url equals: bundle1 url.
	self deny: multiBundle1 flushAndCollectedData isEmpty.
	self assert: multiBundle2 url equals: bundle4 url.
	self deny: multiBundle2 flushAndCollectedData isEmpty.
	self assert: multiBundle1 flushAndCollectedData size equals: 6.
	self assert: multiBundle2 flushAndCollectedData size equals: 2.
	self assert: multiBundle1 flushAndCollectedData first equals: bundle1.
	self assert: multiBundle1 flushAndCollectedData second equals: bundle2.
	self assert: multiBundle1 flushAndCollectedData third equals: bundle3.
	self assert: multiBundle1 flushAndCollectedData fourth equals: bundle1.
	self assert: multiBundle1 flushAndCollectedData fifth equals: bundle2.
	self assert: multiBundle1 flushAndCollectedData sixth equals: bundle3.
	self assert: multiBundle2 flushAndCollectedData first equals: bundle4.
	self assert: multiBundle2 flushAndCollectedData second equals: bundle4.

]

{ #category : 'tests' }
EREventMultiBundleFactoryTest >> testFromBundles3 [
	"#fromBundles: can also receive GTMultiBundle object. It should be consolidate too."
	multiBundles := factory fromBundles: self allBundles.
	multiBundles := factory fromBundles: (multiBundles copy asOrderedCollection
		addAll: self allBundles;
		yourself) asArray.
	self assert: multiBundles size equals: 2.
	self detectEvents.
	self assert: multiBundle1 url equals: bundle1 url.
	self deny: multiBundle1 flushAndCollectedData isEmpty.
	self assert: multiBundle2 url equals: bundle4 url.
	self deny: multiBundle2 flushAndCollectedData isEmpty.
	self assert: multiBundle1 flushAndCollectedData size equals: 6.
	self assert: multiBundle2 flushAndCollectedData size equals: 2.
	self assert: multiBundle1 flushAndCollectedData first equals: bundle1.
	self assert: multiBundle1 flushAndCollectedData second equals: bundle2.
	self assert: multiBundle1 flushAndCollectedData third equals: bundle3.
	self assert: multiBundle1 flushAndCollectedData fourth equals: bundle1.
	self assert: multiBundle1 flushAndCollectedData fifth equals: bundle2.
	self assert: multiBundle1 flushAndCollectedData sixth equals: bundle3.
	self assert: multiBundle2 flushAndCollectedData first equals: bundle4.
	self assert: multiBundle2 flushAndCollectedData second equals: bundle4.

]

{ #category : 'tests' }
EREventMultiBundleFactoryTest >> testFromBundles4 [
	"#fromBundles: can also receive GTMultiBundle object. It should be consolidate too."
	multiBundles := factory fromBundles: self allBundles.
	multiBundles := factory fromBundles: multiBundles.
	self assert: multiBundles size equals: 2.
	self detectEvents.
	self assert: multiBundle1 url equals: bundle1 url.
	self deny: multiBundle1 flushAndCollectedData isEmpty.
	self assert: multiBundle2 url equals: bundle4 url.
	self deny: multiBundle2 flushAndCollectedData isEmpty.
	self assert: multiBundle1 flushAndCollectedData size equals: 3.
	self assert: multiBundle2 flushAndCollectedData size equals: 1.
	self assert: multiBundle1 flushAndCollectedData first equals: bundle1.
	self assert: multiBundle1 flushAndCollectedData second equals: bundle2.
	self assert: multiBundle1 flushAndCollectedData third equals: bundle3.
	self assert: multiBundle2 flushAndCollectedData first equals: bundle4.

]
