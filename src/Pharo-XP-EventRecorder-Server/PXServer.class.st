"
I run the Pharo-XP event ingestion server.

Local defaults:
- host: localhost
- port: 8008
- endpoint: /events
- data directory: ./var/data

I own a dedicated Zinc server instance instead of using Zinc's global default
server, so loading me does not interfere with unrelated HTTP services in the
same Pharo image.
"
Class {
	#name : #PXServer,
	#superclass : #EREventRecorderServer,
	#classInstVars : [
		'devMode',
		'port',
		'dataDirectory',
		'server'
	],
	#category : #'Pharo-XP-EventRecorder-Server'
}

{ #category : #configuration }
PXServer class >> dataDirectory [

	^ dataDirectory ifNil: [
		dataDirectory := FileLocator workingDirectory / 'var' / 'data' ]
]

{ #category : #configuration }
PXServer class >> dataDirectory: aFileReference [

	dataDirectory := aFileReference asFileReference
]

{ #category : #configuration }
PXServer class >> defaultPort [

	^ 8008
]

{ #category : #configuration }
PXServer class >> devMode [

	^ devMode ifNil: [ devMode := false ]
]

{ #category : #configuration }
PXServer class >> devMode: aBoolean [

	devMode := aBoolean
]

{ #category : #accessing }
PXServer class >> endpointURL [

	^ (self serverURL , '/events') asZnUrl
]

{ #category : #configuration }
PXServer class >> port [

	^ port ifNil: [ port := self defaultPort ]
]

{ #category : #configuration }
PXServer class >> port: anInteger [

	(anInteger isInteger and: [ anInteger between: 1 and: 65535 ])
		ifFalse: [ self error: 'Port must be an integer between 1 and 65535' ].
	port := anInteger
]

{ #category : #configuration }
PXServer class >> resetConfiguration [

	self stop.
	devMode := nil.
	port := nil.
	dataDirectory := nil
]

{ #category : #accessing }
PXServer class >> server [

	^ server
]

{ #category : #accessing }
PXServer class >> serverURL [

	^ 'http://localhost:' , self port printString
]

{ #category : #'start-stop' }
PXServer class >> start [

	<example>
	self stop.
	self dataDirectory ensureCreateDirectory.
	server := ZnServer on: self port.
	server
		route: 'Pharo-XP Event Recorder';
		delegate: (PXServerDelegate new
			dataDirectory: self dataDirectory;
			yourself);
		start.
	^ server
]

{ #category : #'start-stop' }
PXServer class >> stop [

	<example>
	server ifNotNil: [
		server stop.
		server := nil ]
]
