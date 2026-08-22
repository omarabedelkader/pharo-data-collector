Class {
	#name : #ERSafeStonPacking,
	#superclass : #ERStonPacking,
	#category : #'EventRecorder-Support'
}

{ #category : #'as yet unclassified' }
ERSafeStonPacking >> fallbackSanitizeAndSerialize: anObject [

	^ anObject isString
		  ifTrue: [ self fallbackSanitizeAndSerializeString: anObject ]
		  ifFalse: [ super serialize: anObject ]
]

{ #category : #'as yet unclassified' }
ERSafeStonPacking >> fallbackSanitizeAndSerializeString: aString [

	| sanitizer sanitizedString |
	sanitizer := ERSTONTextSanitizer new.
	self trySerialize: aString callback: [ :success :serialization | 
		success
			ifTrue: [ ^ serialization ]
			ifFalse: [ "should register the error somehow" ] ].
	sanitizedString := sanitizer removeWideCharacters: aString.
	self
		trySerialize: sanitizedString
		callback: [ :success :serialization | 
			success
				ifTrue: [ ^ serialization ]
				ifFalse: [ "should register the error somehow" ] ].
	sanitizedString := sanitizer removeNonAlphanumericNorSpace:
		                   sanitizedString.
	self
		trySerialize: sanitizedString
		callback: [ :success :serialization | 
			success
				ifTrue: [ ^ serialization ]
				ifFalse: [ "should register the error somehow" ] ].
	self error: 'All fallback serialization attempts failed'
]

{ #category : #private }
ERSafeStonPacking >> serialize: anObject [
	^ self fallbackSanitizeAndSerialize: anObject
]

{ #category : #'as yet unclassified' }
ERSafeStonPacking >> trySerialize: aString callback: aBlock [

	"aBlock is a closure with two parameters, the first is a boolean that tells if there were no errors, and the second is the result of the serialization"

	| serialization success |
	[ serialization := super serialize: aString.
	  self materialize: serialization.
	  success := true]
		on: Exception
		do: [ success := false ].
	aBlock value: success value: serialization
]
