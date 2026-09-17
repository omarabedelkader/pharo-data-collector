"
I represent basic privacy question about collecting user activities and other data that helps to improve Pharo and related tools.

Responsibility: 
I keep information about sending diagnostic and usage data. 

Collaborators:
I only keep the privacy information. All services that collects diagnostic and usage data should do it only if #sendDiagnosticsAndUsageData is true. 

If you want to add more specific settings related to privacy, you can put it to the privacy group.

Public API and Key Messages

- sendDiagnosticsAndUsageData   

"
Class {
	#name : 'ERRecorderSettings',
	#superclass : 'Object',
	#classInstVars : [
		'sendDiagnosticsAndUsageData',
		'sendEntityNames',
		'sendSourceCode',
		'url',
		'localStoragePath'
	],
	#category : 'EventRecorder-PrivacySettings',
	#package : 'EventRecorder',
	#tag : 'PrivacySettings'
}

{ #category : 'cleanup' }
ERRecorderSettings class >> cleanUp [

	sendDiagnosticsAndUsageData := nil.
	sendEntityNames := nil.
	sendSourceCode := nil.
	url := nil
]

{ #category : 'accessing' }
ERRecorderSettings class >> localStoragePath [
	
	^ localStoragePath ifNil: [ localStoragePath := FileLocator home ]
]

{ #category : 'accessing' }
ERRecorderSettings class >> localStoragePath: aFileLocator [
	
	localStoragePath := aFileLocator
]

{ #category : 'settings' }
ERRecorderSettings class >> localStoragePathSettingsOn: aBuilder [
	<systemsettings>
	
	(aBuilder setting: #localStoragePath)
		label: 'Local Storage Path';
		noOrdering;
		description: 'The path where the data will be saved';
		default: FileLocator home;
		parent: #privacy
]

{ #category : 'settings' }
ERRecorderSettings class >> privacySettingsOn: aBuilder [
	<systemsettings>

	(aBuilder group: #privacy)
		label: 'Send Diagnostics And Usage';
		noOrdering;
		description: 'All settings concerned with privacy when collecting coding sessions.'
]

{ #category : 'accessing' }
ERRecorderSettings class >> sendDiagnosticsAndUsageData [
	^ sendDiagnosticsAndUsageData ifNil: [ sendDiagnosticsAndUsageData := false ]
]

{ #category : 'accessing' }
ERRecorderSettings class >> sendDiagnosticsAndUsageData: aBoolean [
	sendDiagnosticsAndUsageData = aBoolean ifTrue: [ ^ self ].
	sendDiagnosticsAndUsageData := aBoolean.
	SystemAnnouncer uniqueInstance announce: ERPrivacyChangedAnnouncement.
]

{ #category : 'settings' }
ERRecorderSettings class >> sendDiagnosticsAndUsageUsageDataSettingsOn: aBuilder [
	<systemsettings>
	
	(aBuilder setting: #sendDiagnosticsAndUsageData)
		label: 'Send telemetric usage data only (acceptance/ignored completion suggestions)';
		noOrdering;
		description: 'Help the Pharo community improve its products and services by automatically sending diagnostic and usage data.';
		default: false;
		parent: #privacy
]

{ #category : 'accessing' }
ERRecorderSettings class >> sendEntityNames [
	^ sendEntityNames ifNil: [ sendEntityNames := false ]
]

{ #category : 'accessing' }
ERRecorderSettings class >> sendEntityNames: aBoolean [
	sendEntityNames := aBoolean
]

{ #category : 'settings' }
ERRecorderSettings class >> sendEntityNamesSettingsOn: aBuilder [
	<systemsettings>
	(aBuilder setting: #sendEntityNames)
		label: 'Include package/class/method names';
		noOrdering;
		description: 'Help the Pharo community improve its tools by automatically sending package, class, or method names as part of usage data, e.g., completed method selector, browsed classes, changed methods.';
		default: false;
		parent: #privacy
]

{ #category : 'accessing' }
ERRecorderSettings class >> sendSourceCode [
	^ sendSourceCode ifNil: [ sendSourceCode := false ]
]

{ #category : 'accessing' }
ERRecorderSettings class >> sendSourceCode: aBoolean [
	sendSourceCode := aBoolean
]

{ #category : 'settings' }
ERRecorderSettings class >> sendSourceCodeSettingsOn: aBuilder [
	<systemsettings>
	
	(aBuilder setting: #sendSourceCode)
		label: 'Include source code';
		noOrdering;
		description: 'Help the Pharo community improve its products and services by automatically sending source code as part of the diagnostic and usage data, e.g., changed methods, browsed source code, written code snippets.';
		default: false;
		parent: #privacy
]

{ #category : 'accessing' }
ERRecorderSettings class >> stringUrl [

	^ self url asString
]

{ #category : 'accessing' }
ERRecorderSettings class >> stringUrl: aUrlString [

	^ self url: aUrlString
]

{ #category : 'accessing' }
ERRecorderSettings class >> url [
	
	^ url ifNil: [ url := 'http://localhost:8008/xp/events' asZnUrl ]
]

{ #category : 'accessing' }
ERRecorderSettings class >> url: aZnUrl [

	url := aZnUrl ifNotNil: [ aZnUrl asZnUrl ]
]

{ #category : 'settings' }
ERRecorderSettings class >> urlSettingsOn: aBuilder [

	<systemsettings>
	(aBuilder setting: #stringUrl)
		target: self;
		description: 'The default URL for the EventRecorder server.';
		label: 'EventRecorder URL';
		parent: #privacy
]
