Class {
	#name : #PXServerIntegrationTest,
	#superclass : #TestCase,
	#instVars : [
		'fileSystem',
		'delegate',
		'server',
		'client',
		'serverSemaphore'
	],
	#category : #'Pharo-XP-EventRecorder-Server-Tests'
}

{ #category : #running }
PXServerIntegrationTest >> setUp [

	super setUp.
	serverSemaphore := Semaphore new.
	fileSystem := FileSystem memory.
	delegate := PXServerDelegate new.
	delegate dataDirectory: fileSystem workingDirectory / 'data'.
	server := EREventRecorderTestServer new.
	server initializeUsingDelegate: delegate semaphore: serverSemaphore.
	client := ZnClient new
		url: server url;
		followRedirects: false;
		numberOfRetries: 0;
		enforceHttpSuccess: true;
		yourself
]

{ #category : #running }
PXServerIntegrationTest >> tearDown [

	server ifNotNil: [
		server stop.
		server unsubscribeAll ].
	super tearDown
]

{ #category : #tests }
PXServerIntegrationTest >> testHealthCheck [

	client path: '/'; get.
	self assert: client isSuccess.
	self assert: client contents equals: 'OK', String crlf
]

{ #category : #tests }
PXServerIntegrationTest >> testEventsHealthCheck [

	client path: '/events'; get.
	self assert: client isSuccess.
	self assert: client contents equals: 'OK', String crlf
]

{ #category : #tests }
PXServerIntegrationTest >> testPutPXBundleStoresPayloadInMetadataHierarchy [

	| bundle multiBundle directory files |
	bundle := PXEventBundle new
		url: (server url copy addPathSegment: 'events'; yourself);
		category: 'category';
		experienceId: 'experience';
		participantUUID: 'participant-1';
		taskOrSurveyId: 'task-1';
		data: #[ 1 2 3 4 ];
		yourself.
	multiBundle := PXEventMultiBundle new
		url: bundle url;
		add: bundle;
		yourself.

	client
		path: '/events';
		entity: multiBundle entity;
		put.

	self assert: client isSuccess.
	self assert: client isCreated.
	directory := fileSystem workingDirectory / 'data' / 'category' / 'experience' / 'participant-1' / 'task-1'.
	self assert: directory exists.
	files := directory allFiles.
	self assert: files size equals: 1.
	self
		assert: (files first binaryReadStreamDo: [ :stream | stream upToEnd ])
		equals: #[ 1 2 3 4 ]
]
