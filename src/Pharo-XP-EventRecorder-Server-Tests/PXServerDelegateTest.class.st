Class {
	#name : #PXServerDelegateTest,
	#superclass : #TestCase,
	#category : #'Pharo-XP-EventRecorder-Server-Tests'
}

{ #category : #tests }
PXServerDelegateTest >> testEventsRoutesUsePXPutHandler [

	| delegate |
	delegate := PXServerDelegate new.
	self
		assert: (delegate dispatcher dispatcherDictionary at: '/events')
		identicalTo: delegate putHandler.
	self
		assert: (delegate dispatcher dispatcherDictionary at: '/events/')
		identicalTo: delegate putHandler
]

{ #category : #tests }
PXServerDelegateTest >> testPutHandler [

	self assert: PXServerDelegate new putHandler class identicalTo: PXEventRecorderPutHandler
]
