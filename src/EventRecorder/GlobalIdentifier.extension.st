Extension { #name : 'GlobalIdentifier' }

{ #category : '*EventRecorder' }
GlobalIdentifier >> obfuscateIfNecessary: anObject [
	^ EREventRecorder sendEntityNames
			ifTrue: [ anObject ]
			ifFalse: [ self obfuscate: anObject ]
]
