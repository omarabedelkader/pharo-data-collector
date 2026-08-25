"
I'm a simple window to display privacy information based on previously set settings.
"
Class {
	#name : 'ERPrivacyAgreementPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'text',
		'settingButton'
	],
	#category : 'EventRecorder-UI',
	#package : 'EventRecorder-UI'
}

{ #category : 'actions' }
ERPrivacyAgreementPresenter class >> openSettingsBrowser [
	| settingsBrowser window |
	settingsBrowser := SettingBrowser new 
		changePackageSet: {PackageOrganizer default packageNamed: 'EventRecorder'};
		yourself.
	window := settingsBrowser open.	
	settingsBrowser expandAll.

]

{ #category : 'actions' }
ERPrivacyAgreementPresenter class >> sample [

	<script>
	
	^ self new open 
]

{ #category : 'initialize' }
ERPrivacyAgreementPresenter >> defaultLayout [ 

	^ SpBoxLayout newVertical
			add: #text;
			add:
			(SpBoxLayout newVertical
				add: #settingButton withConstraints: [ :constraints | constraints height: 28 ];
				yourself) 
			expand: true
		;
		yourself
]

{ #category : 'initialize' }
ERPrivacyAgreementPresenter >> initializePresenters [

	super initializePresenters.
	text := self newText.
	text text: self privacyMessage.
	settingButton := self newButton.
	settingButton
		label: 'Go to setting ';
		action: [ self openSettingsBrowser ].
]

{ #category : 'initialize' }
ERPrivacyAgreementPresenter >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: self title;
		initialExtent: 400 @ 200
]

{ #category : 'initialize' }
ERPrivacyAgreementPresenter >> notSendingMessage [

	^ 'No diagnostic and usage data is being sent. Would you like to send diagnostic and usage data to help us improve Pharo?'
]

{ #category : 'initialize' }
ERPrivacyAgreementPresenter >> openSettingsBrowser [
	self class openSettingsBrowser
]

{ #category : 'initialize' }
ERPrivacyAgreementPresenter >> privacyMessage [

	^ self sendUsageData 
		ifTrue: [ self sendingMessage ]
		ifFalse: 	[ self notSendingMessage ]
]

{ #category : 'initialize' }
ERPrivacyAgreementPresenter >> sendUsageData [	
	^ ERPrivacySettings sendDiagnosticsAndUsageData 
]

{ #category : 'initialize' }
ERPrivacyAgreementPresenter >> sendingMessage [

	^ 'You are sending diagnostic and usage data to help us improve Pharo. Thanks!' 
]

{ #category : 'initialize' }
ERPrivacyAgreementPresenter >> title [

	^ 'Privacy agreement'
]
