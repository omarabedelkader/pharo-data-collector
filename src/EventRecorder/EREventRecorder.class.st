"
I coordinate collectors, packing, privacy, and delivery. Collectors queue events; the packing strategy serializes them into bundles; and the delivery service sends those bundles to their configured endpoints. The class-side #uniqueInstance provides the global recorder used by registered collectors.

Public API and Key Messages

- addCollector: it adds EREventCollector object and activates delivery process if inactive
- removeCollector: it removes  EREventCollector object and deactivates delivery process if there are no other collectors.
- activateDelivery: activates delivery process
- deactivateDelivery: deactivates delivery process

Internal Representation and Key Implementation Points.

    Instance Variables
	announcer:		<Annoucner>
	collectors:		<EREventCollectors>
	delivery:		<EREventDelivery>
	packing:		<EREventPacking>
	privacy:		<true|false|ClosureBlock>

"
Class {
	#name : #EREventRecorder,
	#superclass : #Object,
	#instVars : [
		'collectors',
		'delivery',
		'packing',
		'privacy',
		'announcer'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'EventRecorder-Core'
}

{ #category : #cleanup }
EREventRecorder class >> cleanUp [
	self reset.
]

{ #category : #initialization }
EREventRecorder class >> initializeUniqueInstance [
	uniqueInstance ifNotNil: [ ^ uniqueInstance ].
	uniqueInstance := self new.
	self registerInterestToSystemAnnouncement.
	^ uniqueInstance
]

{ #category : #testing }
EREventRecorder class >> isGlobalRecorder: anEventRecorder [
	^ uniqueInstance
			ifNil: false
			ifNotNil: [ :anInstance | anInstance == anEventRecorder ]
]

{ #category : #initialization }
EREventRecorder class >> registerInterestToSystemAnnouncement [
	<systemEventRegistration>

	uniqueInstance ifNil: [ ^ self ].
	SystemAnnouncer uniqueInstance
		unsubscribe: uniqueInstance.
	SystemAnnouncer uniqueInstance weak
			when: ERPrivacyChangedAnnouncement
			send: #privacyChanged
			to: uniqueInstance
]

{ #category : #initialization }
EREventRecorder class >> reset [
	"Stop delivery, unsubscribe from system announcements, and discard the global recorder."
	uniqueInstance ifNil: [ ^ self ].
	SystemAnnouncer uniqueInstance unsubscribe: uniqueInstance.
	uniqueInstance deactivateDelivery ifNotNil: [ :aProcess |
			[ aProcess terminate ] on: Error do: [ "ignore error" ] ].
	uniqueInstance := nil.
]

{ #category : #accessing }
EREventRecorder class >> uniqueInstance [
	uniqueInstance ifNil: [ self initializeUniqueInstance ].
	^ uniqueInstance
]

{ #category : #delivery }
EREventRecorder >> activateDelivery [
	^ delivery activate
]

{ #category : #delivery }
EREventRecorder >> activateDeliveryIfAvailable [
	^ self canSendDiagnosticsAndUsageData
		ifTrue: [ self activateDelivery ]
		ifFalse: [ nil ]
]

{ #category : #adding }
EREventRecorder >> addCollector: anEventCollector [
	self activateDeliveryIfAvailable.
	^ collectors add: anEventCollector
]

{ #category : #accessing }
EREventRecorder >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #testing }
EREventRecorder >> canSendDiagnosticsAndUsageData [
	^ privacy value
]

{ #category : #delivery }
EREventRecorder >> deactivateDelivery [
	^ delivery deactivate
]

{ #category : #delivery }
EREventRecorder >> deliverNow [
	delivery now
]

{ #category : #accessing }
EREventRecorder >> delivery [
	"Testing purpose."
	^ delivery
]

{ #category : #configuration }
EREventRecorder >> deliveryPreSuspendingAction: aBlockClosure [
	self delivery preSuspendingAction: aBlockClosure
]

{ #category : #packing }
EREventRecorder >> eventConsolidatorClass [
	^ EREventConsolidate
]

{ #category : #packing }
EREventRecorder >> flush [
	"Discard all events currently queued by registered collectors."
	collectors do: #flush
]

{ #category : #initialization }
EREventRecorder >> initialize [
	super initialize.
	privacy := [ ERPrivacy sendDiagnosticsAndUsageData ].
	collectors := EREventCollectors new.
	delivery := EREventDelivery new.
	delivery recorder: self.
	packing := EREventPacking default.
	self canSendDiagnosticsAndUsageData
			ifTrue: [ delivery offerPermission ]
			ifFalse: [ delivery withdrawPermission ]
]

{ #category : #testing }
EREventRecorder >> isDeliveryActive [
	^ delivery isActive
]

{ #category : #testing }
EREventRecorder >> isGlobalRecorder [
	^ self class isGlobalRecorder: self
]

{ #category : #convenient }
EREventRecorder >> numberOfCollectors [
	^ collectors size
]

{ #category : #convenient }
EREventRecorder >> numberOfDeliveryData [
	^ delivery size
]

{ #category : #configuration }
EREventRecorder >> offerDeliveryPermission [
	delivery offerPermission
]

{ #category : #configuration }
EREventRecorder >> offerPrivacy [
	"testing purpose"
	privacy := true
]

{ #category : #packing }
EREventRecorder >> pack [
	| allCollectors consolidatedCollectors |
	self canSendDiagnosticsAndUsageData ifFalse: [ ^ self flush; yourself ].
	allCollectors := OrderedCollection new: collectors size.
	collectors do: [ :eachCollector | allCollectors addLast: eachCollector ].
	consolidatedCollectors := self eventConsolidatorClass new collectors: allCollectors; consolidated.
	consolidatedCollectors do: [ :eachCollector | | bundle |
		eachCollector size > 0 ifTrue: [
			bundle := packing pack: eachCollector.
			delivery add: bundle ] ].
	self removeLiberatedCollectors.
]

{ #category : #'event handling' }
EREventRecorder >> privacyChanged [
	self canSendDiagnosticsAndUsageData
		ifTrue: [ self numberOfCollectors > 0
						ifTrue: [ self activateDelivery ] ]
		ifFalse: [ self deactivateDelivery ]
]

{ #category : #removing }
EREventRecorder >> removeCollector: anEventCollector [
	| removedCollector |
	removedCollector := collectors remove: anEventCollector.
	collectors size = 0 ifTrue: [ self deactivateDelivery ].
	^ removedCollector
]

{ #category : #removing }
EREventRecorder >> removeLiberatedCollectors [
	collectors removeLiberatedCollectors
]

{ #category : #configuration }
EREventRecorder >> withdrawDeliveryPermission [
	delivery withdrawPermission
]

{ #category : #configuration }
EREventRecorder >> withdrawPrivacy [
	"testing purpose"
	privacy := false
]
