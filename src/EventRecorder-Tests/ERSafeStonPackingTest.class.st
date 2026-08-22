Class {
	#name : #ERSafeStonPackingTest,
	#superclass : #EREventPackingTest,
	#category : #'EventRecorder-Tests-Support'
}

{ #category : #accessing }
ERSafeStonPackingTest >> packingClass [
	^ ERSafeStonPacking
]

{ #category : #test }
ERSafeStonPackingTest >> testFallbackSanitizeAndSerialize [

	"Tests that the fallback operations are executed. On first fail, it removes WideString characters.
	On second failure, it removes non (alphanumeric or space) characters."

	| packingForTest |
	packingForTest := ERSafeStonPackingForTests new.
	packingForTest materializeCallCounter: 0.
	packingForTest failOnCounter: 1.
	"should remove widestring characters"
	self
		assert: (packingForTest materialize:
				 (packingForTest fallbackSanitizeAndSerialize: '’asd.'))
		equals: 'asd.'.
	packingForTest materializeCallCounter: 0.
	packingForTest failOnCounter: 2.
	"should remove non (alphanumeric or space) characters"
	self
		assert: (packingForTest materialize:
				 (packingForTest fallbackSanitizeAndSerialize: '’asd.'))
		equals: 'asd'
]

{ #category : #test }
ERSafeStonPackingTest >> testSerialize [

	"Tests that serialization of known problematic cases for packaging succeeds"

	packing serialize: '’'
]
