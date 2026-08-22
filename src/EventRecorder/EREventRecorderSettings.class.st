"
I hold the default endpoint used by EREventCollector.
The standalone EventRecorder server listens locally on port 8080 by default.
"
Class {
	#name : #EREventRecorderSettings,
	#superclass : #Object,
	#classInstVars : [
		'url'
	],
	#category : #'EventRecorder-Settings'
}

{ #category : #cleanup }
EREventRecorderSettings class >> cleanUp [

	url := nil
]

{ #category : #accessing }
EREventRecorderSettings class >> stringUrl [

	^ self url asString
]

{ #category : #accessing }
EREventRecorderSettings class >> stringUrl: aUrlString [

	^ self url: aUrlString
]

{ #category : #accessing }
EREventRecorderSettings class >> url [

	^ url ifNil: [ url := 'http://localhost:8080/gt/events' asZnUrl ]
]

{ #category : #accessing }
EREventRecorderSettings class >> url: aZnUrl [

	url := aZnUrl ifNotNil: [ aZnUrl asZnUrl ]
]

{ #category : #settings }
EREventRecorderSettings class >> urlSettingsOn: aBuilder [

	<systemsettings>
	(aBuilder setting: #stringUrl)
		target: self;
		description: 'The default URL for the EventRecorder server.';
		label: 'EventRecorder URL'
]
