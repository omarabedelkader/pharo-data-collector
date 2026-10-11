"
I'm the central object of the client side event recording and publishing process.

I coordinate collectors, packing, privacy, and delivery. 
- Collectors (instance of `EREventCollector`) queue events; 
- the packing strategy (instance of `EREventPacking`) serializes them into bundles; 
- and the delivery service (instance of `EREventDelivery`) sends those bundles to their configured endpoints. 

The class-side #uniqueInstance provides the global recorder used by registered collectors.

- Collectors should register to me using the message `EREventCollector new register`.


Public API and Key Messages

- addCollector: it adds an `EREventCollector` object and activates delivery process if inactive
- removeCollector: it removes  the `EREventCollector` object and deactivates delivery process if there are no other collectors.
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
	#name : 'EREventRecorder',
	#superclass : 'Object',
	#instVars : [
		'collectors',
		'delivery',
		'packing',
		'privacy',
		'announcer'
	],
	#classInstVars : [
		'uniqueInstance',
		'sendDiagnosticsAndUsageData',
		'sendEntityNames',
		'sendSourceCode',
		'url',
		'localStoragePath'
	],
	#category : 'EventRecorder-Core',
	#package : 'EventRecorder',
	#tag : 'Core'
}

{ #category : 'cleanup' }
EREventRecorder class >> cleanUp [

	self reset
]

{ #category : 'initialization' }
EREventRecorder class >> initializeUniqueInstance [

	uniqueInstance ifNotNil: [ ^ uniqueInstance ].
	uniqueInstance := self new.
	self registerInterestToSystemAnnouncement.
	^ uniqueInstance
]

{ #category : 'testing' }
EREventRecorder class >> isGlobalRecorder: anEventRecorder [

	^ uniqueInstance
			ifNil: [ false ]
			ifNotNil: [ :anInstance | anInstance == anEventRecorder ]
]

{ #category : 'accessing' }
EREventRecorder class >> localStoragePath [
	
	^ localStoragePath ifNil: [ localStoragePath := FileLocator home ]
]

{ #category : 'accessing' }
EREventRecorder class >> localStoragePath: aFileLocator [
	
	localStoragePath := aFileLocator
]

{ #category : 'settings' }
EREventRecorder class >> localStoragePathSettingsOn: aBuilder [
	<systemsettings>
	
	(aBuilder setting: #localStoragePath)
		label: 'Local Storage Path';
		target: self;
		noOrdering;
		description: 'The path where the data will be saved';
		default: FileLocator home;
		parent: #privacy
]

{ #category : 'settings' }
EREventRecorder class >> privacySettingsOn: aBuilder [
	<systemsettings>

	(aBuilder group: #privacy)
		label: 'Send Diagnostics And Usage';
		target: self;
		noOrdering;
		description: 'All settings concerned with privacy when collecting coding sessions.'
]

{ #category : 'initialization' }
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

{ #category : 'initialization' }
EREventRecorder class >> reset [
	"Stop delivery, unsubscribe from system announcements, and discard the global recorder."
	
	uniqueInstance ifNil: [ ^ self ].
	SystemAnnouncer uniqueInstance unsubscribe: uniqueInstance.
	uniqueInstance deactivateDelivery ifNotNil: [ :aProcess |
			[ aProcess terminate ] 
				on: Error 
				do: [ :e | 
					Transcript show: 'Resetting a recorder failed!' 
					"ignore error" ] ]. 
	uniqueInstance := nil.
	sendDiagnosticsAndUsageData := nil.
	sendEntityNames := nil.
	sendSourceCode := nil.
	url := nil
]

{ #category : 'accessing' }
EREventRecorder class >> sendDiagnosticsAndUsageData [
	^ sendDiagnosticsAndUsageData ifNil: [ sendDiagnosticsAndUsageData := false ]
]

{ #category : 'accessing' }
EREventRecorder class >> sendDiagnosticsAndUsageData: aBoolean [
	sendDiagnosticsAndUsageData = aBoolean ifTrue: [ ^ self ].
	sendDiagnosticsAndUsageData := aBoolean.
	SystemAnnouncer uniqueInstance announce: ERPrivacyChangedAnnouncement.
]

{ #category : 'accessing' }
EREventRecorder class >> sendEntityNames [
	^ sendEntityNames ifNil: [ sendEntityNames := false ]
]

{ #category : 'settings' }
EREventRecorder class >> sendEntityNamesSettingsOn: aBuilder [
	<systemsettings>
	(aBuilder setting: #sendEntityNames)
		label: 'Include package/class/method names';
		noOrdering;
		target: EREventRecorder ;
		description: 'Help the Pharo community improve its tools by automatically sending package, class, or method names as part of usage data, e.g., completed method selector, browsed classes, changed methods.';
		default: false;
		parent: #privacy
]

{ #category : 'accessing' }
EREventRecorder class >> sendSourceCode [
	^ sendSourceCode ifNil: [ sendSourceCode := false ]
]

{ #category : 'accessing' }
EREventRecorder class >> sendSourceCode: aBoolean [
	sendSourceCode := aBoolean
]

{ #category : 'settings' }
EREventRecorder class >> sendSourceCodeSettingsOn: aBuilder [
	<systemsettings>
	
	(aBuilder setting: #sendSourceCode)
		label: 'Include source code';
		noOrdering;
		target: EREventRecorder ;
		description: 'Help the Pharo community improve its products and services by automatically sending source code as part of the diagnostic and usage data, e.g., changed methods, browsed source code, written code snippets.';
		default: false;
		parent: #privacy
]

{ #category : 'accessing' }
EREventRecorder class >> stringUrl [

	^ self url asString
]

{ #category : 'accessing' }
EREventRecorder class >> stringUrl: aUrlString [

	^ self url: aUrlString
]

{ #category : 'for development' }
EREventRecorder class >> todebug [
	<script>
	Halt resetOnce.
	EREventRecorder uniqueInstance log: '2'.
	EREventRecorder uniqueInstance delivery now.
]

{ #category : 'accessing' }
EREventRecorder class >> uniqueInstance [

	uniqueInstance ifNil: [ self initializeUniqueInstance ].
	^ uniqueInstance
]

{ #category : 'accessing' }
EREventRecorder class >> url [
	
	^ url ifNil: [ url := 'http://localhost:8080/xp/events' asZnUrl ]
]

{ #category : 'accessing' }
EREventRecorder class >> url: aZnUrl [

	url := aZnUrl ifNotNil: [ aZnUrl asZnUrl ]
]

{ #category : 'settings' }
EREventRecorder class >> urlSettingsOn: aBuilder [

	<systemsettings>
	(aBuilder setting: #stringUrl)
		target: EREventRecorder ;
		description: 'The default URL for the EventRecorder server.';
		label: 'EventRecorder URL';
		parent: #privacy
]

{ #category : 'delivery' }
EREventRecorder >> activateDelivery [
	^ delivery activate
]

{ #category : 'delivery' }
EREventRecorder >> activateDeliveryIfAvailable [
	^ self canSendDiagnosticsAndUsageData
		ifTrue: [ self activateDelivery ]
		ifFalse: [ nil ]
]

{ #category : 'adding' }
EREventRecorder >> addCollector: anEventCollector [

	self activateDeliveryIfAvailable.
	anEventCollector recorder: self. 
	^ collectors add: anEventCollector
]

{ #category : 'accessing' }
EREventRecorder >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : 'testing' }
EREventRecorder >> canSendDiagnosticsAndUsageData [
	
	^ privacy value
]

{ #category : 'delivery' }
EREventRecorder >> deactivateDelivery [
	^ delivery deactivate
]

{ #category : 'delivery' }
EREventRecorder >> deliverNow [
	delivery now
]

{ #category : 'accessing' }
EREventRecorder >> delivery [
	"Testing purpose."
	^ delivery
]

{ #category : 'configuration' }
EREventRecorder >> deliveryPreSuspendingAction: aBlockClosure [
	self delivery preSuspendingAction: aBlockClosure
]

{ #category : 'packing' }
EREventRecorder >> eventConsolidatorClass [
	^ EREventConsolidate
]

{ #category : 'packing' }
EREventRecorder >> flush [
	"Discard all events currently queued by registered collectors."
	
	collectors do: [:each | each flush]
]

{ #category : 'initialization' }
EREventRecorder >> initialize [
	super initialize.
	privacy := [ self class sendDiagnosticsAndUsageData ].
	collectors := EREventCollectors new.

	delivery := EREventDelivery new.
	delivery recorder: self.
	
	packing := EREventPacking default.
	self canSendDiagnosticsAndUsageData
			ifTrue: [ delivery offerPermission ]
			ifFalse: [ delivery withdrawPermission ]
]

{ #category : 'testing' }
EREventRecorder >> isDeliveryActive [
	^ delivery isActive
]

{ #category : 'testing' }
EREventRecorder >> isGlobalRecorder [
	^ self class isGlobalRecorder: self
]

{ #category : 'logging' }
EREventRecorder >> log: info [
	"not sure that it should be in this class"
	
	| collector |
	collector := EREventCollector new. 
	collector category: 'complishon2'.
	collector register. 
	collector add: info.
]

{ #category : 'convenient' }
EREventRecorder >> numberOfCollectors [
	^ collectors size
]

{ #category : 'convenient' }
EREventRecorder >> numberOfDeliveryData [
	^ delivery size
]

{ #category : 'configuration' }
EREventRecorder >> offerDeliveryPermission [
	delivery offerPermission
]

{ #category : 'configuration' }
EREventRecorder >> offerPrivacy [
	"testing purpose"
	privacy := true
]

{ #category : 'packing' }
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

{ #category : 'event handling' }
EREventRecorder >> privacyChanged [
	self canSendDiagnosticsAndUsageData
		ifTrue: [ self numberOfCollectors > 0
						ifTrue: [ self activateDelivery ] ]
		ifFalse: [ self deactivateDelivery ]
]

{ #category : 'removing' }
EREventRecorder >> removeCollector: anEventCollector [
	"When the last collector is removed, the delivery is deactivated."

	| removedCollector |
	removedCollector := collectors remove: anEventCollector.
	collectors size = 0 ifTrue: [ self deactivateDelivery ].
	^ removedCollector
]

{ #category : 'removing' }
EREventRecorder >> removeLiberatedCollectors [
	collectors removeLiberatedCollectors
]

{ #category : 'configuration' }
EREventRecorder >> withdrawDeliveryPermission [
	delivery withdrawPermission
]

{ #category : 'configuration' }
EREventRecorder >> withdrawPrivacy [
	"testing purpose"
	privacy := false
]
