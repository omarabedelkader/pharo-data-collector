Class {
	#name : 'ERPrivacyAgreementPresenterTest',
	#superclass : 'TestCase',
	#category : 'EventRecorder-UI-Tests',
	#package : 'EventRecorder-UI-Tests'
}

{ #category : 'tests' }
ERPrivacyAgreementPresenterTest >> testMessage [

	| previousSetting |
	[ | presenter |
	previousSetting := ERRecorderSettings sendDiagnosticsAndUsageData.
	presenter := ERPrivacyAgreementPresenter new.
	ERRecorderSettings sendDiagnosticsAndUsageData: true.
	self assert: presenter privacyMessage equals: presenter sendingMessage.
	ERRecorderSettings sendDiagnosticsAndUsageData: false.
	self assert: presenter privacyMessage equals: presenter notSendingMessage ]
		ensure: [ ERRecorderSettings sendDiagnosticsAndUsageData: previousSetting ]
]

{ #category : 'tests' }
ERPrivacyAgreementPresenterTest >> testOpenWindowAddsItToWindowCollection [

	| presenter |
	self shouldnt: [ presenter := ERPrivacyAgreementPresenter new open ] raise: MessageNotUnderstood.
	presenter close
]
