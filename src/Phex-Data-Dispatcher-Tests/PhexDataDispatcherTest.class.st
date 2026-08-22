Class {
	#name : #PhexDataDispatcherTest,
	#superclass : #TestCase,
	#instVars : [
		'fileSystem',
		'targetServer',
		'dispatcherServer',
		'targetSemaphore',
		'dispatcherSemaphore',
		'receivedTargetRequests',
		'receivedTargetRequestSemaphore'
	],
	#category : #'Phex-Data-Dispatcher-Tests'
}

{ #category : #private }
PhexDataDispatcherTest >> dispatcherRedirectionsTo: aZnUrl [

	^ Dictionary new
		at: 'incoming'
			put: (Dictionary new
				at: 'host' put: aZnUrl host;
				at: 'port' put: aZnUrl port;
				at: 'path' put: 'target';
				yourself);
		yourself
]

{ #category : #private }
PhexDataDispatcherTest >> dispatcherSymbolRedirectionsTo: aZnUrl [

	^ Dictionary new
		at: #incoming
			put: (Dictionary new
				at: #host put: aZnUrl host;
				at: #port put: aZnUrl port;
				at: #path put: #target;
				yourself);
		yourself
]

{ #category : #private }
PhexDataDispatcherTest >> newOkDelegate [

	| delegate |
	delegate := ZnDispatcherDelegate new.
	delegate
		map: '/target'
		to: [ :request :response | ZnResponse ok: (ZnEntity textCRLF: 'forwarded') ].
	delegate
		map: '/target/details'
		to: [ :request :response |
			ZnResponse ok: (ZnEntity textCRLF: 'forwarded-details') ].
	^ delegate
]

{ #category : #private }
PhexDataDispatcherTest >> newRequestCapturingDelegate [

	| delegate |
	delegate := ZnDispatcherDelegate new.
	delegate
		map: '/target/upload'
		to: [ :request :response |
			receivedTargetRequests nextPut: request.
			receivedTargetRequestSemaphore signal.
			ZnResponse created: 'forwarded' ].
	^ delegate
]

{ #category : #running }
PhexDataDispatcherTest >> setUp [

	super setUp.
	fileSystem := FileSystem memory.
	targetSemaphore := Semaphore new.
	dispatcherSemaphore := Semaphore new.
	receivedTargetRequests := WaitfreeQueue new.
	receivedTargetRequestSemaphore := Semaphore new
]

{ #category : #private }
PhexDataDispatcherTest >> startDispatcherTo: aZnUrl [

	self startDispatcherWithRedirections: (self dispatcherRedirectionsTo: aZnUrl)
]

{ #category : #private }
PhexDataDispatcherTest >> startDispatcherWithRedirections: aDictionary [

	| dispatcher |
	dispatcher := PhexDataDispatcher new.
	dispatcher redirections: aDictionary.
	dispatcherServer := EREventRecorderTestServer new.
	dispatcherServer
		initializeUsingDelegate: dispatcher
		semaphore: dispatcherSemaphore
]

{ #category : #private }
PhexDataDispatcherTest >> startTargetServer [

	targetServer := EREventRecorderTestServer new.
	targetServer
		initializeUsingDelegate: self newOkDelegate
		semaphore: targetSemaphore
]

{ #category : #private }
PhexDataDispatcherTest >> startTargetServerWithDelegate: aDelegate [

	targetServer := EREventRecorderTestServer new.
	targetServer
		initializeUsingDelegate: aDelegate
		semaphore: targetSemaphore
]

{ #category : #running }
PhexDataDispatcherTest >> tearDown [

	dispatcherServer ifNotNil: [
		dispatcherServer stop.
		dispatcherServer unsubscribeAll ].
	targetServer ifNotNil: [
		targetServer stop.
		targetServer unsubscribeAll ].
	PhexDataDispatcher resetConfiguration.
	super tearDown
]

{ #category : #tests }
PhexDataDispatcherTest >> testForwardsConfiguredRequest [

	| client |
	self startTargetServer.
	self startDispatcherTo: targetServer url.
	client := ZnClient new
		url: dispatcherServer url;
		path: '/incoming';
		enforceHttpSuccess: true;
		yourself.

	client get.

	self assert: client contents equals: 'forwarded' , String crlf
]

{ #category : #tests }
PhexDataDispatcherTest >> testForwardsPutRequestWithEntity [

	| client entity forwardedRequest |
	self startTargetServerWithDelegate: self newRequestCapturingDelegate.
	self startDispatcherTo: targetServer url.
	entity := ZnByteArrayEntity bytes: #[ 1 2 3 4 ].
	client := ZnClient new
		url: dispatcherServer url;
		path: '/incoming/upload';
		entity: entity;
		enforceHttpSuccess: true;
		yourself.

	client put.

	self assert: client isCreated.
	self deny: (receivedTargetRequestSemaphore waitTimeoutMilliseconds: 200).
	receivedTargetRequests flush: [ :request | forwardedRequest := request ].
	self assert: forwardedRequest method asString equals: 'PUT'.
	self assert: forwardedRequest contents equals: #[ 1 2 3 4 ]
]

{ #category : #tests }
PhexDataDispatcherTest >> testConfiguredPathSegmentsIgnoreEmptySegments [

	| dispatcher redirection request segments |
	dispatcher := PhexDataDispatcher new.
	redirection := Dictionary new
		at: 'path' put: '/target/base/';
		yourself.
	request := ZnRequest get: '/incoming/details/more' asZnUrl.

	segments := dispatcher
		configuredPathSegmentsFor: redirection
		request: request.

	self
		assert: segments asArray
		equals: #( 'target' 'base' 'details' 'more' )
]

{ #category : #tests }
PhexDataDispatcherTest >> testForwardsAdditionalPathSegments [

	| client |
	self startTargetServer.
	self startDispatcherTo: targetServer url.
	client := ZnClient new
		url: dispatcherServer url;
		path: '/incoming/details';
		enforceHttpSuccess: true;
		yourself.

	client get.

	self assert: client contents equals: 'forwarded-details' , String crlf
]

{ #category : #tests }
PhexDataDispatcherTest >> testForwardsRedirectionWithSymbolKeys [

	| client |
	self startTargetServer.
	self startDispatcherWithRedirections:
		(self dispatcherSymbolRedirectionsTo: targetServer url).
	client := ZnClient new
		url: dispatcherServer url;
		path: '/incoming';
		enforceHttpSuccess: true;
		yourself.

	client get.

	self assert: client contents equals: 'forwarded' , String crlf
]

{ #category : #tests }
PhexDataDispatcherTest >> testMissingRedirectionFieldRaisesError [

	self
		should: [
			PhexDataDispatcher new
				valueAt: 'host'
				in: Dictionary new ]
		raise: Error
]

{ #category : #tests }
PhexDataDispatcherTest >> testMissingRedirectionReturnsServerError [

	| dispatcher response |
	dispatcher := PhexDataDispatcher new.
	dispatcher redirections: Dictionary new.
	response := dispatcher handleRequest: (ZnRequest get: '/missing' asZnUrl).

	self assert: response statusLine code equals: 500.
	self assert: response contents equals: 'The redirection of /missing path is not configured.'
]

{ #category : #tests }
PhexDataDispatcherTest >> testReadsRedirectionsFromJsonFile [

	| file redirections |
	file := fileSystem workingDirectory / 'redirections.json'.
	file writeStreamDo: [ :stream |
		stream nextPutAll:
			'{"incoming":{"host":"localhost","port":8008,"path":"events"}}' ].

	redirections := PhexDataDispatcher redirectionsFromFile: file.

	self assert: ((redirections at: 'incoming') at: 'host') equals: 'localhost'.
	self assert: ((redirections at: 'incoming') at: 'port') equals: 8008.
	self assert: ((redirections at: 'incoming') at: 'path') equals: 'events'
]
