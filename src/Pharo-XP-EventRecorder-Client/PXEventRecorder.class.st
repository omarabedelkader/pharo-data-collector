"
I specialize EREventRecorder for Pharo-XP experiments. I use PX-aware
consolidation and a short delivery interval suitable for experiment sessions.

The client endpoint is configurable. Local development defaults to
http://localhost:8008/events.
"
Class {
	#name : 'PXEventRecorder',
	#superclass : 'EREventRecorder',
	#classInstVars : [
		'endpoint'
	],
	#category : 'Pharo-XP-EventRecorder-Client',
	#package : 'Pharo-XP-EventRecorder-Client'
}

{ #category : 'configuration' }
PXEventRecorder class >> defaultEndpoint [

	^ 'http://localhost:8008/events' asZnUrl
]

{ #category : 'configuration' }
PXEventRecorder class >> endpoint [

	^ endpoint ifNil: [ endpoint := self defaultEndpoint ]
]

{ #category : 'configuration' }
PXEventRecorder class >> endpoint: aUrl [

	endpoint := aUrl asZnUrl
]

{ #category : 'configuration' }
PXEventRecorder class >> resetEndpoint [

	endpoint := nil
]

{ #category : 'delivery' }
PXEventRecorder >> activateDelivery [

	delivery standardDuration: 1 second.
	^ delivery activate
]

{ #category : 'packing' }
PXEventRecorder >> eventConsolidatorClass [

	^ PXEventConsolidate
]
