"
I represent a collection of EREventCollector objects. EREventRecorder uses me and I am responsible for adding and removing the collectors.

Public API and Key Messages

- add:  
- remove:
 
Internal Representation and Key Implementation Points.

    Instance Variables
	collectors:		<OrderedCollection>
	mutex:		<Mutex>

"
Class {
	#name : 'EREventCollectors',
	#superclass : 'Object',
	#instVars : [
		'mutex',
		'collectors'
	],
	#category : 'EventRecorder-Support',
	#package : 'EventRecorder',
	#tag : 'Support'
}

{ #category : 'adding' }
EREventCollectors >> add: anEventCollector [
	^ mutex critical: [ 
		(collectors identityIncludes: anEventCollector)
			ifFalse: [ collectors add: anEventCollector ]
			ifTrue: [ anEventCollector ] ]
]

{ #category : 'enumerating' }
EREventCollectors >> do: oneArgBlock [
	mutex critical: [ collectors do: oneArgBlock ]
]

{ #category : 'initialization' }
EREventCollectors >> initialize [
	super initialize.
	mutex := Mutex new.
	collectors := OrderedCollection new.
]

{ #category : 'accessing' }
EREventCollectors >> numberOfEvents [
	^ mutex critical: [ 
		collectors 
			ifEmpty: 0
			ifNotEmpty: [ collectors sum: #size ] ]
]

{ #category : 'printing' }
EREventCollectors >> printOn: aStream [
	super printOn: aStream.
	aStream
		space;
		nextPut: $[;
		print: self size;
		space;
		nextPutAll: ('collector' asPluralBasedOn: self size);
		nextPutAll: ', ';
		print: self numberOfEvents;
		space;
		nextPutAll: ('event' asPluralBasedOn: self numberOfEvents);
		nextPut: $]
]

{ #category : 'removing' }
EREventCollectors >> remove: anEventCollector [ 
	^ mutex critical: [ collectors remove: anEventCollector ifAbsent: nil ]
]

{ #category : 'removing' }
EREventCollectors >> removeLiberatedCollectors [
	mutex critical: [ | liberated |
		liberated := collectors select: #isLiberated.
		collectors removeAll: liberated ]
]

{ #category : 'accessing' }
EREventCollectors >> size [
	^ mutex critical: [ collectors size ]
]
