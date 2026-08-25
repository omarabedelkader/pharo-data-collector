Extension { #name : 'GlobalIdentifier' }

{ #category : '*EventRecorder' }
GlobalIdentifier >> obfuscateIfNecessary: anObject [
	^ ERPrivacySettings sendEntityNames
			ifTrue: [ anObject ]
			ifFalse: [ self obfuscate: anObject ]
]
