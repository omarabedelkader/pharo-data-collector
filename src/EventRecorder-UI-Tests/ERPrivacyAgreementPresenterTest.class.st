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
	previousSetting := ERPrivacySettings sendDiagnosticsAndUsageData.
	presenter := ERPrivacyAgreementPresenter new.
	ERPrivacySettings sendDiagnosticsAndUsageData: true.
	self assert: presenter privacyMessage equals: presenter sendingMessage.
	ERPrivacySettings sendDiagnosticsAndUsageData: false.
	self assert: presenter privacyMessage equals: presenter notSendingMessage ]
		ensure: [ ERPrivacySettings sendDiagnosticsAndUsageData: previousSetting ]
]

{ #category : 'tests' }
ERPrivacyAgreementPresenterTest >> testOpenWindowAddsItToWindowCollection [

	| presenter |
	self shouldnt: [ presenter := ERPrivacyAgreementPresenter new open ] raise: MessageNotUnderstood.
	presenter close
]
