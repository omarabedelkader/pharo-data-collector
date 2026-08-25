Class {
	#name : 'PXEventRecorderConfigurationTest',
	#superclass : 'TestCase',
	#category : 'Pharo-XP-EventRecorder-Client-Tests',
	#package : 'Pharo-XP-EventRecorder-Client-Tests'
}

{ #category : 'running' }
PXEventRecorderConfigurationTest >> tearDown [

	PXEventRecorder resetEndpoint.
	super tearDown
]

{ #category : 'tests' }
PXEventRecorderConfigurationTest >> testCollectorUsesLocalEndpointByDefault [

	self
		assert: PXEventCollector new url
		equals: 'http://localhost:8008/events' asZnUrl
]

{ #category : 'tests' }
PXEventRecorderConfigurationTest >> testEndpointCanBeConfigured [

	PXEventRecorder endpoint: 'https://example.test/events'.
	self
		assert: PXEventCollector new url
		equals: 'https://example.test/events' asZnUrl
]
