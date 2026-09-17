Extension { #name : 'GlobalIdentifier' }

{ #category : '*EventRecorder' }
GlobalIdentifier >> obfuscateIfNecessary: anObject [
	^ ERRecorderSettings sendEntityNames
			ifTrue: [ anObject ]
			ifFalse: [ self obfuscate: anObject ]
]
