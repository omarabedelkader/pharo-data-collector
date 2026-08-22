"
I am an HTTP dispatcher that forwards incoming requests to configured targets.

Redirections are read from a JSON file with this shape:

{
  ""events"" : {
    ""host"" : ""localhost"",
    ""port"" : 8008,
    ""path"" : ""events""
  }
}

Starting a dispatcher on port 8080 with that configuration forwards
http://localhost:8080/events to http://localhost:8008/events.
"
Class {
	#name : #PhexDataDispatcher,
	#superclass : #Object,
	#instVars : [
		'server',
		'redirections'
	],
	#classInstVars : [
		'instance',
		'redirectionsFile'
	],
	#category : #'Phex-Data-Dispatcher'
}

{ #category : #configuration }
PhexDataDispatcher class >> defaultRedirectionsFile [

	^ Smalltalk imageDirectory / 'redirections.json'
]

{ #category : #accessing }
PhexDataDispatcher class >> redirections [

	^ self redirectionsFromFile: self redirectionsFile
]

{ #category : #configuration }
PhexDataDispatcher class >> redirectionsFile [

	^ redirectionsFile ifNil: [ redirectionsFile := self defaultRedirectionsFile ]
]

{ #category : #configuration }
PhexDataDispatcher class >> redirectionsFile: aFileReference [

	redirectionsFile := aFileReference asFileReference
]

{ #category : #accessing }
PhexDataDispatcher class >> redirectionsFromFile: aFileReference [

	| file |
	file := aFileReference asFileReference.
	file exists ifFalse: [
		self error: 'Missing dispatcher redirections file: ' , file fullName ].
	^ STONJSON fromString: file contents
]

{ #category : #configuration }
PhexDataDispatcher class >> resetConfiguration [

	self stopIfRunning.
	redirectionsFile := nil
]

{ #category : #accessing }
PhexDataDispatcher class >> start: aPort [

	instance ifNil: [ instance := self new ].
	instance
		redirections: self redirections;
		start: aPort.
	^ instance
]

{ #category : #accessing }
PhexDataDispatcher class >> start: aPort redirectionsFile: aFileReference [

	self redirectionsFile: aFileReference.
	^ self start: aPort
]

{ #category : #accessing }
PhexDataDispatcher class >> stop [

	instance ifNil: [
		self error: 'No PhexDataDispatcher instance is running. Use #start: first.' ].
	instance stop.
	instance := nil
]

{ #category : #accessing }
PhexDataDispatcher class >> stopIfRunning [

	instance ifNil: [ ^ self ].
	instance stop.
	instance := nil
]

{ #category : #private }
PhexDataDispatcher >> configuredPathSegmentsFor: redirection request: aRequest [

	| path segments |
	path := (self valueAt: 'path' in: redirection) asString.
	segments := OrderedCollection new.
	segments addAll: ((path splitOn: $/) reject: [ :segment | segment isEmpty ]).
	aRequest uri segments size > 1 ifTrue: [
		segments addAll: aRequest uri segments allButFirst ].
	^ segments
]

{ #category : #public }
PhexDataDispatcher >> handleRequest: aRequest [

	| redirection segments |
	redirection := self redirectionFor: aRequest ifAbsent: [
		^ ZnResponse new
			statusLine: ZnStatusLine internalServerError;
			entity: (ZnEntity text:
				('The redirection of {1} path is not configured.'
					format: { aRequest uri }));
			yourself ].
	segments := self
		configuredPathSegmentsFor: redirection
		request: aRequest.
	^ ZnClient new
		request: aRequest;
		host: (self valueAt: 'host' in: redirection);
		port: (self valueAt: 'port' in: redirection);
		path: (segments joinUsing: $/);
		streaming: true;
		execute;
		response
]

{ #category : #private }
PhexDataDispatcher >> redirectionFor: aRequest ifAbsent: absentBlock [

	| incomingPath |
	incomingPath := aRequest uri segments
		ifEmpty: [ '' ]
		ifNotEmpty: [ :segments | segments first ].
	^ self redirections
		at: incomingPath
		ifAbsent: [
			self redirections
				at: incomingPath asSymbol
				ifAbsent: absentBlock ]
]

{ #category : #accessing }
PhexDataDispatcher >> redirections [

	^ redirections
]

{ #category : #accessing }
PhexDataDispatcher >> redirections: aDictionary [

	redirections := aDictionary
]

{ #category : #accessing }
PhexDataDispatcher >> start: aPort [

	self stop.
	server := ZnServer on: aPort.
	server
		route: 'Phex Data Dispatcher';
		delegate: self;
		start
]

{ #category : #accessing }
PhexDataDispatcher >> stop [

	server ifNotNil: [
		server stop.
		server := nil ]
]

{ #category : #private }
PhexDataDispatcher >> valueAt: key in: aDictionary [

	^ aDictionary
		at: key
		ifAbsent: [
			aDictionary
				at: key asSymbol
				ifAbsent: [ self error: 'Missing dispatcher redirection field: ' , key ] ]
]
