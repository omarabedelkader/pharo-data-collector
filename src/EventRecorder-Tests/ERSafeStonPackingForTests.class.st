"
Class used for testing SafeStonPacking. It is able to generate ""a failure"" (Exeception) on certain materialize calls, and like that, it controls how far the fallback algorithm gets to.
"
Class {
	#name : #ERSafeStonPackingForTests,
	#superclass : #ERSafeStonPacking,
	#instVars : [
		'failOnCounter',
		'materializeCallCounter'
	],
	#category : #'EventRecorder-Tests-Support'
}

{ #category : #accessing }
ERSafeStonPackingForTests >> failOnCounter [

	^ failOnCounter
]

{ #category : #accessing }
ERSafeStonPackingForTests >> failOnCounter: anObject [

	failOnCounter := anObject
]

{ #category : #initialization }
ERSafeStonPackingForTests >> initialize [

	failOnCounter := 0.
	materializeCallCounter := 0
]

{ #category : #private }
ERSafeStonPackingForTests >> materialize: anObject [

	materializeCallCounter := materializeCallCounter + 1.
	materializeCallCounter = failOnCounter ifTrue: [ 
		Exception new signal ].
	^ super materialize: anObject 
]

{ #category : #accessing }
ERSafeStonPackingForTests >> materializeCallCounter [

	^ materializeCallCounter
]

{ #category : #accessing }
ERSafeStonPackingForTests >> materializeCallCounter: anObject [

	materializeCallCounter := anObject
]
