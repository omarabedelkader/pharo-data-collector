"
I know how to deliver usage and diagnostic data to a remote server.

I maintain a background process that periodically asks the recorder to pack collected events and sends the resulting bundles to their target URLs. Failed deliveries are re-queued for a later attempt.

Public API and Key Messages

- #activate initializes the delivery process; clients must call this method; it's not called automatically on object creation.
- #deliveryCycle implements  the main logic of the delivery process
"
Class {
	#name : 'EREventDelivery',
	#superclass : 'Object',
	#instVars : [
		'mutex',
		'process',
		'delay',
		'permission',
		'recorder',
		'queue',
		'preSuspendingAction',
		'standardDuration'
	],
	#category : 'EventRecorder-Support',
	#package : 'EventRecorder',
	#tag : 'Support'
}

{ #category : 'defaults' }
EREventDelivery class >> defaultStandardDuration [
	^ 20 minutes
]

{ #category : 'activation' }
EREventDelivery >> activate [
	"Initialize a delivery process."
	^ mutex critical: [
			self offerPermission.
			self isInactive ifTrue: [ self initializeProcess ].
			process ]
]

{ #category : 'adding' }
EREventDelivery >> add: anEventBundle [
	queue nextPut: anEventBundle
]

{ #category : 'announce' }
EREventDelivery >> announceSuspendingDelivery [
	preSuspendingAction ifNotNil: #value
]

{ #category : 'accessing' }
EREventDelivery >> announcer [
	^ self recorder ifNotNil: #announcer
]

{ #category : 'deactivation' }
EREventDelivery >> deactivate [
	^ mutex critical: [ | oldProcess |
		self withdrawPermission.
		delay ifNotNil: [ :aDelay | aDelay delaySemaphore signal ].
		oldProcess := process.
		process := nil.
		oldProcess ]
]

{ #category : 'delivery' }
EREventDelivery >> deliver: aBoolean [
	| bundles |
	bundles := EREventMultiBundleFactory fromBundles: self flushAndCollectedData.
	bundles do: [ :eachMultiBundle |
		self deliver: eachMultiBundle signalProgress: aBoolean ]
]

{ #category : 'delivery' }
EREventDelivery >> deliver: aMultiBundle signalProgress: aBoolean [
	^ (ZnClient new
			beOneShot;
			timeout: 5;
			signalProgress: aBoolean;
			numberOfRetries: 0;
			url: aMultiBundle url;
			enforceHttpSuccess: true;
			ifFail: [ :exception | queue nextPut: aMultiBundle ];
			entity: aMultiBundle entity;
			put;
			response)
]

{ #category : 'initialization' }
EREventDelivery >> deliveryCycle [
	delay := self standardDuration asDelay.
	self announceSuspendingDelivery.
	delay wait.
	delay := nil.
	self hasPermission ifTrue: [ self packAndDeliver: false ]
]

{ #category : 'delivery' }
EREventDelivery >> flushAndCollectedData [
	"This drains the delivery queue; callers must not use it for inspection."
	| eventBundles |
	eventBundles := OrderedCollection new.
	queue flush: [ :eachEventBundle | eventBundles addLast: eachEventBundle ].
	^ eventBundles
]

{ #category : 'testing' }
EREventDelivery >> hasPermission [
	^ permission
]

{ #category : 'initialization' }
EREventDelivery >> initialize [
	super initialize.
	mutex := Mutex new.
	queue := WaitfreeQueue new.
	permission := true.
	standardDuration := 20 minutes
]

{ #category : 'initialization' }
EREventDelivery >> initializeProcess [
	process := [ [ self hasPermission ] whileTrue: [ self deliveryCycle ] ]
		forkAt: Processor userBackgroundPriority
		named: self printProcessName
]

{ #category : 'testing' }
EREventDelivery >> isActive [
	^ self isInactive not
]

{ #category : 'testing' }
EREventDelivery >> isGlobalRecorder [
	^ self recorder
			ifNil: false
			ifNotNil: #isGlobalRecorder
]

{ #category : 'testing' }
EREventDelivery >> isInactive [
	^ mutex critical: [
		process isNil or: [
			process isTerminated or: [
				process isTerminating ] ] ]
]

{ #category : 'delivery' }
EREventDelivery >> now [
	"for testing purpose"
	delay ifNotNil: [ :aDelay | aDelay delaySemaphore signal. aDelay unschedule. ]
]

{ #category : 'activation' }
EREventDelivery >> offerPermission [
	mutex critical: [ permission := true ]
]

{ #category : 'delivery' }
EREventDelivery >> packAndDeliver: aBoolean [
	recorder pack.
	self deliver: aBoolean
]

{ #category : 'initialization' }
EREventDelivery >> preSuspendingAction: aBlockClosure [
	preSuspendingAction := aBlockClosure
]

{ #category : 'printing' }
EREventDelivery >> printOn: aStream [
	super printOn: aStream.
	aStream
		space;
		nextPut: $[;
		print: queue size;
		space;
		nextPutAll: ('item' asPluralBasedOn: queue size).
	self isActive
		ifTrue: [
			delay
				ifNil: [ aStream nextPutAll: 'process active, but delay is nil!' ]
				ifNotNil: [ :aDelay |
					aStream
						nextPutAll: ', next cycle in ';
						print: (aDelay millisecondsToGo milliSeconds roundTo: 1 second);
						nextPutAll: ' sec' ] ]
		ifFalse: [
			aStream nextPutAll: ', inactive' ].
	aStream
		nextPut: $]
]

{ #category : 'printing' }
EREventDelivery >> printProcessName [
	^ String streamContents: [ :aStream |
		self printProcessNameOn: aStream ]
]

{ #category : 'printing' }
EREventDelivery >> printProcessNameOn: aStream [
	aStream
		nextPutAll: self className.
	self isGlobalRecorder
		ifTrue: [ aStream nextPutAll: ' global ' ]
		ifFalse: [ aStream nextPutAll: ' a ' ].
	aStream nextPutAll: 'delivery process'
]

{ #category : 'accessing' }
EREventDelivery >> recorder [
	^ recorder
]

{ #category : 'accessing' }
EREventDelivery >> recorder: anObject [
	recorder := anObject
]

{ #category : 'accessing' }
EREventDelivery >> size [
	^ queue size
]

{ #category : 'accessing' }
EREventDelivery >> standardDuration [
	^ standardDuration ifNil:[standardDuration := self class defaultStandardDuration]
]

{ #category : 'accessing' }
EREventDelivery >> standardDuration: aDuration [

	standardDuration := aDuration
]

{ #category : 'deactivation' }
EREventDelivery >> withdrawPermission [
	mutex critical: [ permission := false ]
]
