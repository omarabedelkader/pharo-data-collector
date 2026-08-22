"
I am an utility used to sanitize strings used in the experiment framework.

Experimentally, we have detected that some characters crash serialization and/or packaging of string when using ERStonPacking.
Failure Example: 
ERStonPacking new materialize: (ERStonPacking new serialize: '’').
Will fail. $’ is a wide character. We don't know the real reason of the failure or if other characters will poduce a failure.
"
Class {
	#name : #ERSTONTextSanitizer,
	#superclass : #Object,
	#category : #'EventRecorder-Support'
}

{ #category : #removing }
ERSTONTextSanitizer >> removeNonAlphanumericNorSpace: aString [

	"returns a ByteString which is a copy of the original, without widestring characters"

	^ aString select: [ :c | c isAlphaNumeric or: c isSpaceSeparator ]
]

{ #category : #removing }
ERSTONTextSanitizer >> removeWideCharacters: aString [

	"returns a ByteString which is a copy of the original, without widestring characters"

	^ aString select: [ :c | c isOctetCharacter ]
]
