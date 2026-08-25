"
I am weak holder of an object that uses EREventCollector. If the object disappears from object memory (or #liberate message is sent), EREventCollector can be removed from a EREventRecorder object.

For the Collaborators Part: EREventCollector

Public API and Key Messages

- object: 
- liberate
- isLiberated

Internal Representation and Key Implementation Points.

    Instance Variables
	weakHolder:		<Object>

"
Class {
	#name : 'EREventRegistry',
	#superclass : 'Object',
	#instVars : [
		'weakHolder'
	],
	#category : 'EventRecorder-Support',
	#package : 'EventRecorder',
	#tag : 'Support'
}

{ #category : 'initialization' }
EREventRegistry >> initialize [
	super initialize.
	weakHolder := WeakArray new: 1.
]

{ #category : 'testing' }
EREventRegistry >> isLiberated [
	^ (weakHolder at: 1) isNil
]

{ #category : 'actions' }
EREventRegistry >> liberate [
	self object: nil.
]

{ #category : 'accessing' }
EREventRegistry >> object: anObject [ 
	weakHolder at: 1 put: anObject.
]

{ #category : 'printing' }
EREventRegistry >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: (self isLiberated ifTrue: [ 'liberated' ] ifFalse: [ 'used' ]);
		nextPut: $)
]
