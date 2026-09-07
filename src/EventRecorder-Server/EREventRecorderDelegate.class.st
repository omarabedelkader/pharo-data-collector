"
I dispatch EventRecorder HTTP requests. Subclasses customize the handler,
storage, directories, and route map through small factory/configuration hooks.

By default 

```

	| okResponse |
	okResponse := [ :request :response | ZnResponse ok: (ZnEntity text: 'OK - The event recorder server is running!') ].
	dispatcher
		map: '/' to: okResponse;
		map: '/xp' to: okResponse;
		map: '/xp/' to: okResponse;
		map: '/xp/zip' to: zipHandler;
		map: '/xp/zip/' to: zipHandler;
		map: '/xp/events' to: putHandler;
		map: '/xp/events/' to: putHandler;
		yourself
```

"
Class {
	#name : 'EREventRecorderDelegate',
	#superclass : 'Object',
	#instVars : [
		'dispatcher',
		'putHandler',
		'zipHandler'
	],
	#category : 'EventRecorder-Server',
	#package : 'EventRecorder-Server'
}

{ #category : 'configuration' }
EREventRecorderDelegate >> dataDirectory: aFileReference [

	putHandler directory: aFileReference
]

{ #category : 'defaults' }
EREventRecorderDelegate >> defaultDataDirectory [

	^ FileLocator home / 'xp' / 'events'
]

{ #category : 'defaults' }
EREventRecorderDelegate >> defaultZipRootURL [

	^ 'http://gc.dcc.uchile.cl/' asZnUrl
]

{ #category : 'defaults' }
EREventRecorderDelegate >> fileStorageClass [

	^ EREventRecorderFileStorage
]

{ #category : 'public' }
EREventRecorderDelegate >> handleRequest: request [

	^ dispatcher handleRequest: request
]

{ #category : 'initialization' }
EREventRecorderDelegate >> initialize [

	super initialize.
	self initializePutHandler.
	self initializeZipHandler.
	dispatcher := ZnDispatcherDelegate new.
	self initializeDispatcher
]

{ #category : 'initialization' }
EREventRecorderDelegate >> initializeDispatcher [

	| okResponse |
	okResponse := [ :request :response | ZnResponse ok: (ZnEntity text: 'OK - The event recorder server is running!') ].
	dispatcher
		map: '/' to: okResponse;
		map: '/xp' to: okResponse;
		map: '/xp/' to: okResponse;
		map: '/xp/zip' to: zipHandler;
		map: '/xp/zip/' to: zipHandler;
		map: '/xp/events' to: putHandler;
		map: '/xp/events/' to: putHandler;
		yourself
]

{ #category : 'initialization' }
EREventRecorderDelegate >> initializePutHandler [

	putHandler := self putHandlerClass new.
	putHandler storage: (self fileStorageClass new
		directory: self defaultDataDirectory;
		yourself)
]

{ #category : 'initialization' }
EREventRecorderDelegate >> initializeZipHandler [

	zipHandler := EREventRecorderZipHandler new.
	zipHandler
		fileDirectory: self defaultDataDirectory;
		zipRootUrl: self defaultZipRootURL;
		archiver: ERExternalZipScript new
]

{ #category : 'accessing' }
EREventRecorderDelegate >> putHandler [

	^ putHandler
]

{ #category : 'defaults' }
EREventRecorderDelegate >> putHandlerClass [

	^ EREventRecorderPutHandler
]

{ #category : 'accessing' }
EREventRecorderDelegate >> zipHandler [

	^ zipHandler
]
