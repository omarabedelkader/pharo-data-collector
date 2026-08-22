"
I collect events for one category and target URL. The recorder drains my queue when it packs events for delivery. An optional occupant is held weakly so collectors tied to short-lived tools can be removed after their data has been sent.

Public API and Key Messages

- bundle
- url
- category
- occupant:
- register

Example for playing with me:
	EREventCollector new
		category: #testingForFun;
		occupant: nil ""object that represents your application"";
		add: 42;
		add: 'Hallo Pharo user';
		yourself.

Example for serious use:
	EREventCollector new
		category: #testingForReal;
		occupant: nil ""object that represents your application, if nil, the collector will be removed from EREventRecorder object once collected data are sent"";
		register; ""please do not register just for fun, because we collects those data""
		yourself

Internal Representation and Key Implementation Points.

    Instance Variables
	recordedEvents:		<WaitfreeQueue>
	url:		<ZnUrl>

"
Class {
	#name : #EREventCollector,
	#superclass : #Object,
	#instVars : [
		'url',
		'category',
		'recordedEvents',
		'registry',
		'updateAnnouncementBlock'
	],
	#category : #'EventRecorder-Core'
}

{ #category : #examples }
EREventCollector class >> notRegisteredCollector [
	<sampleInstance>

	^ self new
		category: #testingForFun; "the data are stored under the defined category."
		occupant: nil; "object that represents your application, if nil, the collector will be removed from EREventRecorder object once collected data are sent"
		add: 42; "collected data"
		add: 'Hallo Pharo user'; "collected data"
		register; "please, be aware that we collect the data"
		yourself.
]

{ #category : #adding }
EREventCollector >> add: anEvent [
	"Add an event to the queue."
	^ recordedEvents nextPut: anEvent
]

{ #category : #adding }
EREventCollector >> addIfAvailable: anEvent [
	"Add an event only when diagnostic and usage-data delivery is enabled."
	ERPrivacy sendDiagnosticsAndUsageData ifFalse: [ ^ anEvent ].
	^ self add: anEvent
]

{ #category : #accessing }
EREventCollector >> bundle [
	"It returns all collected events that are supposed to be sent. If you need to send just a portion of the collected events, this is the place to overwrite."
	^ self bundle: OrderedCollection new.
]

{ #category : #accessing }
EREventCollector >> bundle: aCollection [
	recordedEvents flush: [ :eachEvent | aCollection addLast: eachEvent ].
	^ aCollection
]

{ #category : #accessing }
EREventCollector >> category [
	^ category ifNil: [ category := self defaultCategory ]
]

{ #category : #accessing }
EREventCollector >> category: aString [
	"It is used for distinguishing data from different application on a server.
	The data are stored separately on a server according to category name."
	^ category := aString
]

{ #category : #configuration }
EREventCollector >> defaultCategory [
	"Subclasses can override this default or clients can configure #category:."
	^ #unknown
]

{ #category : #accessing }
EREventCollector >> flush [
	"Discard all currently queued events."
	recordedEvents flush
]

{ #category : #initialization }
EREventCollector >> initialize [
	super initialize.
	recordedEvents := WaitfreeQueue new.
]

{ #category : #testing }
EREventCollector >> isLiberated [
	"Answer whether I no longer have an occupant or queued events."
	^ self registry isLiberated and: [ recordedEvents isEmpty ]
]

{ #category : #actions }
EREventCollector >> liberate [
	"Liberate me from the occupant so I can be removed from EREventRecorder object in the next delivery cycle."
	^ self registry liberate.
]

{ #category : #packing }
EREventCollector >> newAnnouncement [
	^ EREventAnnouncement new
]

{ #category : #packing }
EREventCollector >> newAnnouncementForPacking [

	| announcement |
	announcement := self newAnnouncement.
	announcement category: self category.
	^ announcement
]

{ #category : #packing }
EREventCollector >> newBundle [

	^ EREventBundle new
]

{ #category : #packing }
EREventCollector >> newBundleForPacking [

	| bundle |
	bundle := self newBundle.
	bundle
		url: self url;
		category: self category.
	^ bundle
]

{ #category : #accessing }
EREventCollector >> occupant: anObject [
	"Hold the producer weakly so this collector does not extend its lifetime."
	self registry object: anObject
]

{ #category : #printing }
EREventCollector >> printOn: aStream [
	super printOn: aStream.
	aStream
		space;
		nextPut: $[;
		print: recordedEvents size;
		space;
		nextPutAll: ('item' asPluralBasedOn: recordedEvents size);
		nextPut: $]
]

{ #category : #initialization }
EREventCollector >> register [
	"Register with the global EventRecorder instance."
	EREventRecorder uniqueInstance addCollector: self.
]

{ #category : #accessing }
EREventCollector >> registry [
	"Answer the weak registry that tracks my producer."
	^ registry ifNil: [ registry := EREventRegistry new ]
]

{ #category : #accessing }
EREventCollector >> size [
	"It returns number of collected events."
	^ recordedEvents size
]

{ #category : #updating }
EREventCollector >> updateAnnouncement: anEventAnnouncement [
	updateAnnouncementBlock ifNil: [ ^ anEventAnnouncement ].
	updateAnnouncementBlock cull: anEventAnnouncement.
	^ anEventAnnouncement
]

{ #category : #updating }
EREventCollector >> updateAnnouncementBlock: aBlockClosure [
	updateAnnouncementBlock := aBlockClosure
]

{ #category : #accessing }
EREventCollector >> url [
	"It returns URL indicating where to send collected data."
	^ url ifNil: [ url := EREventRecorderSettings url ]
]

{ #category : #accessing }
EREventCollector >> url: aZnUrl [
	"URL that indicates where to send collected data."
	url := aZnUrl
]
