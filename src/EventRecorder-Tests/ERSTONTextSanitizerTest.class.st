"
An ExperimentTextSanitizerTest is a test class for testing the behavior of ExperimentTextSanitizer
"
Class {
	#name : #ERSTONTextSanitizerTest,
	#superclass : #TestCase,
	#instVars : [
		'sanitizer'
	],
	#category : #'EventRecorder-Tests-Support'
}

{ #category : #running }
ERSTONTextSanitizerTest >> setUp [

	super setUp.
	sanitizer := ERSTONTextSanitizer new.
	
]

{ #category : #test }
ERSTONTextSanitizerTest >> testRemoveNonAlphanumericNorSpace [

	| stringNoSpace stringWithSpace |
	stringNoSpace := 'alph!anu$meric#PartNoSpac...e'.
	stringWithSpace := 'alphanumeri[cPart[} -=With+./Spa?ce'.
	self assert: (sanitizer removeNonAlphanumericNorSpace: stringNoSpace ) equals: 'alphanumericPartNoSpace'.
	self assert: (sanitizer removeNonAlphanumericNorSpace: stringWithSpace ) equals: 'alphanumericPart WithSpace'
]

{ #category : #test }
ERSTONTextSanitizerTest >> testRemoveWideCharacters [

	| wideString pureWideString |
	wideString := 'byteStringPart' , (Character value: 1000) asString.
	pureWideString := '' join: { 
			                  (Character value: 1000).
			                  (Character value: 1010).
			                  (Character value: 2010).
			                  (Character value: 3010).
			                  (Character value: 4010).
			                  (Character value: 5010) }.
	self
		assert: (sanitizer removeWideCharacters: wideString)
		equals: 'byteStringPart'.
	self
		assert: (sanitizer removeWideCharacters: pureWideString)
		equals: ''
]
