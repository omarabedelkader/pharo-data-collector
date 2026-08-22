"
I dispatch the Pharo-XP HTTP API.

GET /         -> health check
GET /events   -> health check for the ingest endpoint
PUT /events   -> multipart event ingestion
"
Class {
	#name : #PXServerDelegate,
	#superclass : #EREventRecorderDelegate,
	#category : #'Pharo-XP-EventRecorder-Server'
}

{ #category : #defaults }
PXServerDelegate >> defaultDataDirectory [

	^ PXServer dataDirectory
]

{ #category : #accessing }
PXServerDelegate >> dispatcher [

	^ dispatcher
]

{ #category : #defaults }
PXServerDelegate >> fileStorageClass [

	^ PXServerFileStorage
]

{ #category : #public }
PXServerDelegate >> handleRequest: request [

	PXServer devMode ifTrue: [ request crTrace ].
	^ super handleRequest: request
]

{ #category : #initialization }
PXServerDelegate >> initializeDispatcher [

	| okResponse |
	okResponse := [ :request :response | ZnResponse ok: (ZnEntity text: 'OK') ].
	dispatcher
		map: '/' to: okResponse;
		map: '/events' to: putHandler;
		map: '/events/' to: putHandler;
		yourself
]

{ #category : #initialization }
PXServerDelegate >> initializeZipHandler [

	"PX ingestion does not expose the legacy ZIP endpoint."
]

{ #category : #defaults }
PXServerDelegate >> putHandlerClass [

	^ PXEventRecorderPutHandler
]
